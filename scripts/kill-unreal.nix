{ pkgs, lib }:

pkgs.writeShellApplication {
  name = "kill-unreal";
  runtimeInputs = [ pkgs.lsof pkgs.procps ];
  checkPhase = ''bash -n "$target"'';
  bashOptions = [ "errexit" "pipefail" ];
  text = ''
    . ${lib.bashLib}/share/unreal/bash-lib.sh
    clear
    print_banner "UE Process killer & GPU Status"

    echo
    print_header "Looking for Unreal Engine processes..."
    # yay, grep exits 1 on no match
    UNREAL_PROCS=$(find_ue_procs)

    if [ -z "$UNREAL_PROCS" ]; then
      print_success "No running Unreal Engine processes found :)"
    else
      PROC_COUNT=$(echo "$UNREAL_PROCS" | wc -l)
      print_warning "Found $PROC_COUNT running Unreal Engine process:"
      echo "$UNREAL_PROCS" | while read -r line; do
        PID=$(echo "$line" | awk '{print $2}')
        CMD=$(ps -p "$PID" -o args= 2>/dev/null || echo "unknown")
        colorize2 "ACCENT" "NC" "PID: $PID" "Command: $CMD"
      done
      echo
      print_warning "Kill all Unreal Engine processes? [y/N]"
      read -n 1 -r response; echo
      if [[ "$response" =~ ^[Yy]$ ]]; then
        mapfile -t pids < <(echo "$UNREAL_PROCS" | awk '{print $2}')
        for pid in "''${pids[@]}"; do
          kill -15 "$pid" 2>/dev/null && print_info "SIGTERM -> PID $pid"
        done
        sleep 2
        REMAINING=$(find_ue_procs)
        if [ -n "$REMAINING" ]; then
          print_warning "They don't want to die! Some processes survived, sending SIGKILL..."
          mapfile -t remaining_pids < <(echo "$REMAINING" | awk '{print $2}')
          for pid in "''${remaining_pids[@]}"; do
            kill -9 "$pid" 2>/dev/null && print_info "SIGKILL -> PID $pid"
          done
          sleep 1
          STILL=$(find_ue_procs)
          if [ -n "$STILL" ]; then
            print_error "They are strong, i could not terminate all processes :("
            print_base  "Remaining PIDs:"
            echo "$STILL" | awk '{print $2}' | while read -r pid; do
              cmd=$(ps -p "$pid" -o args= 2>/dev/null || echo "unknown")
              print_base "  PID $pid: $cmd"
            done
          else
            print_success "All Unreal Engine processes terminated :)"
          fi
        else
          print_success "All Unreal Engine processes terminated :)"
        fi
      else
        print_info "Cancelled: processes left running."
      fi
    fi

    echo
    print_header "Checking for Unreal cache files..."

    CACHE_PATTERNS=(
      "/tmp/UnrealEngine-*"
      "/tmp/UE5-*"
      "/tmp/Unreal-*"
      "/tmp/UnrealEditor-*"
      "$HOME/.cache/UnrealEngine"
      "$HOME/.cache/unreal-shaders"
      "/dev/shm/UnrealEngine*"
      "/dev/shm/UE5*"
    )

    FOUND_CACHE=()
    for pattern in "''${CACHE_PATTERNS[@]}"; do
      for p in $pattern; do
        [ -e "$p" ] && FOUND_CACHE+=("$p")
      done
    done

    if [ ''${#FOUND_CACHE[@]} -eq 0 ]; then
      print_success "No cache files found :)"
    else
      echo
      print_warning "''${#FOUND_CACHE[@]} cache item(s) found:"
      for p in "''${FOUND_CACHE[@]}"; do
        SIZE=$(du -sh "$p" 2>/dev/null | cut -f1)
        colorize2 "LABEL" "NC" "  [$SIZE]" "$p"
      done
    fi

    echo
    print_header "Checking GPU memory usage..."
    if command -v nvidia-smi &>/dev/null; then
      GPU_PROCESSES=$(nvidia-smi pmon -c 1 2>/dev/null | grep -E "Unreal|UE5" || true)
      [ -n "$GPU_PROCESSES" ] && print_error "UE5 processes still using GPU:" && echo "$GPU_PROCESSES"
      if GPU_MEM_INFO=$(nvidia-smi --query-gpu=name,memory.used,memory.total --format=csv,noheader 2>/dev/null); then
        GPU_NAME=$(echo "$GPU_MEM_INFO"     | cut -d, -f1)
        GPU_MEM_USED=$(echo "$GPU_MEM_INFO"  | cut -d, -f2 | tr -d ' ')
        GPU_MEM_TOTAL=$(echo "$GPU_MEM_INFO" | cut -d, -f3 | tr -d ' ')
        print_info "GPU: $GPU_NAME"
        colorize2 "WARNING" "NC" "Memory:" "$GPU_MEM_USED of $GPU_MEM_TOTAL"
        MEM_USED=$(echo "$GPU_MEM_USED"   | sed 's/[^0-9]//g')
        MEM_TOTAL=$(echo "$GPU_MEM_TOTAL" | sed 's/[^0-9]//g')
        if [ -n "$MEM_USED" ] && [ -n "$MEM_TOTAL" ] && [ "$MEM_TOTAL" -gt 0 ]; then
          PCT=$((MEM_USED * 100 / MEM_TOTAL))
          if   [ "$PCT" -gt 80 ]; then print_error   "GPU memory very high ($PCT%)!"
          elif [ "$PCT" -gt 50 ]; then print_warning "GPU memory medium ($PCT%)"
          else                         print_success "GPU memory normal ($PCT%)"
          fi
        fi
      fi
    elif command -v rocm-smi &>/dev/null; then
      print_info "AMD GPU memory:"; rocm-smi --showmeminfo vram
    else
      print_warning "No GPU monitoring tool found (nvidia-smi / rocm-smi)"
    fi

    echo
    print_header "Checking network connections..."
    mapfile -t net_pids < <(find_ue_procs | awk '{print $2}' || true)
    if [ ''${#net_pids[@]} -eq 0 ]; then
      print_success "No active Unreal Engine processes."
    else
      CONNECTIONS=$(
        for pid in "''${net_pids[@]}"; do
          lsof -i -a -p "$pid" 2>/dev/null
        done
      )
      if [ -n "''${CONNECTIONS:-}" ]; then
        print_warning "Active network connections from UE5 processes:"
        echo "$CONNECTIONS"
      else
        print_success "No active network connections from UE5 processes :)"
      fi
    fi

    echo
    print_banner "Mission completed!"
    print_warning "Press any key to exit..."
    read -n 1 -s
  '';
}

{ pkgs, lib, utils }:

''
  find_and_kill_unreal() {
    echo
    print_header "Looking for target... Unreal Engine processes..."
    UNREAL_PROCS=$(ps aux | grep -E "$UNREAL_PROCESS_PATTERN" | grep -v grep | grep -v "kill-unreal")

    if [ -z "$UNREAL_PROCS" ]; then
      print_success "No running Unreal Engine processes found. Everything is clean... for now :) !"
      return 0
    fi

    # Count the targets
    PROC_COUNT=$(echo "$UNREAL_PROCS" | wc -l)
    print_warning "Found $PROC_COUNT running Unreal Engine processes:"
    echo

    # Process display with proper quoting
    echo "$UNREAL_PROCS" | while read -r line; do
      PID=$(echo "$line" | awk '{print $2}')
      CMD=$(echo "$line" | awk '{$1=$2=$3=$4=$5=$6=$7=$8=$9=$10=""; print $0}' | sed 's/^ *//')
      colorize2 "BRED" "NC" "PID: $PID" "Command: $CMD"
    done

    echo
    print_warning "Do you want to kill all unreal engine processes? [y/N]"
    read -n 1 -r response
    echo

    if [[ "$response" =~ ^[Yy]$ ]]; then
      # First attempt with SIGTERM
      kill_count=0
      for pid in $(echo "$UNREAL_PROCS" | awk '{print $2}'); do
        if kill -15 "$pid" 2>/dev/null; then
          kill_count=$((kill_count + 1))
        fi
      done

      if [ "$kill_count" -gt 0 ]; then
        print_info "Sent termination signal to $kill_count processes."
      fi

      sleep 2

      # Check if still alive and force kill if needed
      REMAINING=$(ps aux | grep -E "$UNREAL_PROCESS_PATTERN" | grep -v grep | grep -v "kill-unreal")
      if [ -n "$REMAINING" ]; then
        print_warning "Double tap, we never know with undead, some might still be alive. Forcing termination..."

        # Too slow, here is the SIGKILL
        kill_count=0
        for pid in $(echo "$REMAINING" | awk '{print $2}'); do
          if kill -9 "$pid" 2>/dev/null; then
            kill_count=$((kill_count + 1))
          fi
        done

        if [ "$kill_count" -gt 0 ]; then
          print_info "Sent force kill signal to $kill_count processes."
        fi

        sleep 1

        # Check again to ensure everything is dead
        STILL_REMAINING=$(ps aux | grep -E "$UNREAL_PROCESS_PATTERN" | grep -v grep | grep -v "kill-unreal")
        if [ -n "$STILL_REMAINING" ]; then
          print_error "Could not terminate all processes. You may need root privileges."
          print_warning "Consider running: sudo killall -9 UnrealEditor"
        else
          print_success "Order done, all Unreal Engine processes have been terminated."
        fi
      else
        print_success "Mission complete, all Unreal Engine processes have been terminated."
      fi
    else
      print_info "Let it live, order cancelled. Processes not killed."
    fi
  }
''
{ pkgs, lib, utils }:

''
  check_gpu_memory() {
    echo
    print_header "Checking GPU memory usage..."

    if command -v nvidia-smi &>/dev/null; then
      GPU_PROCESSES=$(nvidia-smi pmon -c 1 | grep -E "Unreal|UE5")
      if [ -n "$GPU_PROCESSES" ]; then
        print_error "Bad Unreal, found Unreal Engine 5 processes still using GPU resources:"
        echo "$GPU_PROCESSES"
        echo
      fi

      # Check overall memory usage
      if ! GPU_MEM_INFO=$(nvidia-smi --query-gpu=name,memory.used,memory.total --format=csv,noheader); then
        print_error "Failed to get GPU memory metrics."
        return 1
      fi

      GPU_NAME=$(echo "$GPU_MEM_INFO" | cut -d ',' -f 1)
      GPU_MEM_USED=$(echo "$GPU_MEM_INFO" | cut -d ',' -f 2 | tr -d ' ')
      GPU_MEM_TOTAL=$(echo "$GPU_MEM_INFO" | cut -d ',' -f 3 | tr -d ' ')

      print_info "GPU: $GPU_NAME"
      colorize2 "BYELLOW" "NC" "Memory usage:" "$GPU_MEM_USED of $GPU_MEM_TOTAL"

      # Get GPU numerics with safer parsing
      MEM_USED=$(echo "$GPU_MEM_USED" | sed 's/[^0-9]//g')
      MEM_TOTAL=$(echo "$GPU_MEM_TOTAL" | sed 's/[^0-9]//g')

      # Trying to calculate percentage, if possible
      if [ -n "$MEM_USED" ] && [ -n "$MEM_TOTAL" ] && [ "$MEM_TOTAL" -gt 0 ]; then
        PERCENTAGE=$((MEM_USED * 100 / MEM_TOTAL))

        if [ "$PERCENTAGE" -gt 80 ]; then
          print_error "Bad news, your GPU memory usage is very high ($PERCENTAGE%)!"
          print_warning "This might indicate memory leaks from evil Unreal Engine 5 processes."
          print_warning "Unless you started a game... If you did then have fun :)"
          print_warning "But if you already killed all UE5 processes but memory is still high,"
          print_warning "try to restart your GPU driver or rebooting your system."
        elif [ "$PERCENTAGE" -gt 50 ]; then
          print_warning "Meh, weird, GPU memory usage is moderately high ($PERCENTAGE%)."
        else
          print_success "GPU memory usage is normal ($PERCENTAGE%)."
        fi
      fi
    else
      print_warning "nvidia-smi not found. GPU memory check skipped."

      # Try to check AMD GPU metrics
      if command -v rocm-smi &>/dev/null; then
        print_info "Checking AMD GPU memory usage..."
        rocm-smi --showmeminfo vram
      fi
    fi
  }
''
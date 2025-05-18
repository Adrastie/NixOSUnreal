{ pkgs, lib, utils }:

''
  check_network_connections() {
    echo
    print_header "Checking network connections..."

    # Check if lsof is available
    if ! command -v lsof &>/dev/null; then
      print_error "lsof command not found. Network check skipped."
      return 1
    fi

    # Get PIDs of Unreal processes
    UNREAL_PIDS=$(ps aux | grep -E "$UNREAL_PROCESS_PATTERN" | grep -v grep | grep -v "kill-unreal" | awk '{print $2}')

    if [ -z "$UNREAL_PIDS" ]; then
      print_success "No Unreal Engine processes found with active network connections."
      return 0
    fi

    # Checking network connections by PID parsing
    CONNECTIONS=""
    for pid in $UNREAL_PIDS; do
      PROC_CONNECTIONS=$(lsof -i -a -p "$pid" 2>/dev/null)
      if [ -n "$PROC_CONNECTIONS" ]; then
        CONNECTIONS="$CONNECTIONS$PROC_CONNECTIONS"
      fi
    done

    if [ -n "$CONNECTIONS" ]; then
      print_warning "It's alive, found network connections from Unreal Engine 5 processes:"
      echo "$CONNECTIONS"
    else
      print_success "It seems dead for now, no active network connections from Unreal Engine 5 processes were found."
    fi
  }
''
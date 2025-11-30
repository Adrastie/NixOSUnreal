{ pkgs, lib, utils }:

''
  cleanup_temp_files() {
    echo
    print_header "Checking for Unreal temp files..."
    TEMP_DIRS=(
      "/tmp/UnrealEngine-*"
      "/tmp/UE5-*"
      "/tmp/Unreal-*"
      "/tmp/UnrealEditor-*"
      "$HOME/.cache/UnrealEngine"
      "/dev/shm/UnrealEngine*"
      "/dev/shm/UE5*"
    )

    FOUND_FILES=0

    for temp_dir in "''${TEMP_DIRS[@]}"; do
      if find $temp_dir -maxdepth 0 2>/dev/null | grep -q .; then
        FOUND_FILES=1
        colorize2 "YELLOW" "NC" "Found some temp files in:" "$temp_dir"
      fi
    done

    if [ $FOUND_FILES -eq 0 ]; then
      print_success "Amazing, nothing was found! System seem clean!"
      return 0
    fi

  }
''

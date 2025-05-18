{ pkgs, lib, utils }:

''
  cleanup_temp_files() {
    echo
    print_header "Trying to clean Unreal temp files..."
    TEMP_DIRS=(
      "/tmp/UnrealEngine-*"
      "/tmp/UE5-*"
      "/tmp/Unreal-*"
      "/tmp/UnrealEditor-*"
      "$HOME/.cache/UnrealEngine"
      # Unsafe, commented for public repo, do not use! "$HOME/.local/share/UnrealEngine/5.*"
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

    print_warning "UNSAFE, use at your own risk!"
    print_error "Do you want to remove these temporary files? [y/N]"
    read -n 1 -r response
    echo

    if [[ "$response" =~ ^[Yy]$ ]]; then
      for temp_dir in "''${TEMP_DIRS[@]}"; do
        if [ -e "$temp_dir" ]; then
          if [[ "$temp_dir" == *"*"* ]]; then
            find "$(dirname "$temp_dir")" -path "$temp_dir" -print -delete 2>/dev/null
          else
            if [ -d "$temp_dir" ] && [ "$(basename "$temp_dir")" != "/" ] && [[ "$temp_dir" != "/" ]]; then
              rm -rvf "$temp_dir" 2>/dev/null
            fi
          fi
        fi
      done
      print_success "Temps files have been deleted."
    else
      print_info "Deletion cancelled, you are wise!"
    fi
  }
''
{ pkgs, lib, utils }:

''
  create_emergency_script() {
    echo
    print_header "Creating an emergency cleanup script..."
    SCRIPT_PATH="$HOME/kill-unreal-emergency.sh"

    if ! touch "$SCRIPT_PATH" 2>/dev/null; then
      print_error "Cannot create emergency killer script: permission denied on $SCRIPT_PATH"
      return 1
    fi

    cat > "$SCRIPT_PATH" << 'EOF'
#!/bin/bash
echo "Last hope, Emergency Unreal Engine cleanup script"
echo "This script requires sudo privileges"
echo "WARNING: This will forcefully terminate all Unreal Engine processes"
echo

# Destroy all Unreal
echo "Killing all Unreal Engine 5 processes..."
sudo killall -9 UnrealEditor UnrealEditor-Cmd UE5Editor UE5Editor-Cmd 2>/dev/null

# Clean up shm
echo "Cleaning up shared memory..."
sudo rm -rvf /dev/shm/Unreal* /dev/shm/UE5* 2>/dev/null

# Reset nvidia gpu
if command -v nvidia-smi &>/dev/null; then
    echo "Resetting NVIDIA GPU..."
    sudo nvidia-smi --gpu-reset 2>/dev/null || echo "GPU reset not supported on this device"
fi
echo "Emergency cleanup complete!"
EOF

    chmod +x "$SCRIPT_PATH"

    print_success "Emergency cleanup script created at: $SCRIPT_PATH"
    print_warning "Run this script with sudo if failing:"
    print_warning "THE SCRIPT CAN CRASH YOUR GPU, SAVE EVERYTHING FIRST!!!"
    print_warning "sudo $SCRIPT_PATH"
  }
''
{ pkgs, lib, refreshEnvScript }:

pkgs.writeShellApplication {
  name = "vulkan-test-fhs";
  checkPhase = ''bash -n "$target"'';
  bashOptions = [ "errexit" "pipefail" ];
  text = ''
    . ${lib.bashLib}/share/unreal/bash-lib.sh

    GPU_VENDOR=$(detect_gpu_vendor)
    print_banner "Detected GPU vendor: $GPU_VENDOR"
    print_header "PCI display devices"
    ${pkgs.pciutils}/bin/lspci | grep -iE "vga|3d|display"
    echo

    case "$GPU_VENDOR" in
      nvidia)
        print_banner "NVIDIA Driver Version"
        nvidia-smi --query-gpu=driver_version --format=csv,noheader 2>/dev/null \
          || print_error "nvidia-smi not found or failed"
        echo
        print_banner "NVIDIA Devices"
        ls -la /dev/nvidia* 2>/dev/null || print_error "No NVIDIA devices found"
        ;;
      amd)
        print_banner "AMD GPU Info"
        if command -v rocm-smi &>/dev/null; then
          rocm-smi --showdriverversion 2>/dev/null || print_warning "rocm-smi failed"
        else
          print_warning "rocm-smi not found, skipping AMD driver check"
        fi
        ls -la /dev/kfd /dev/dri/render* 2>/dev/null || print_warning "AMD render devices not found"
        ;;
      intel)
        print_banner "Intel GPU Info"
        ls -la /dev/dri/render* 2>/dev/null || print_warning "Intel render devices not found"
        ;;
      *)
        print_warning "Unknown GPU vendor, skipping vendor-specific checks"
        ;;
    esac

    echo
    print_banner "OpenGL Driver Paths"
    REAL_DRIVER_PATH=$(readlink -f /run/opengl-driver 2>/dev/null || echo "")
    REAL_DRIVER_32_PATH=$(readlink -f /run/opengl-driver-32 2>/dev/null || echo "")
    colorize2 "LABEL" "NC" "OpenGL driver path:"       "''${REAL_DRIVER_PATH:-not found}"
    colorize2 "LABEL" "NC" "OpenGL driver-32bit path:" "''${REAL_DRIVER_32_PATH:-not found}"

    echo
    print_banner "Vulkan ICD Files"
    if [ -n "''${REAL_DRIVER_PATH:-}" ] && [ -d "$REAL_DRIVER_PATH/share/vulkan/icd.d" ]; then
      find "$REAL_DRIVER_PATH/share/vulkan/icd.d" -name "*.json" 2>/dev/null
    else
      print_error "No Vulkan ICD files found"
    fi

    echo
    print_banner "Environment Variables"
    colorize2 "WARNING" "NC" "LD_LIBRARY_PATH:"  "$LD_LIBRARY_PATH"
    colorize2 "WARNING" "NC" "VK_ICD_FILENAMES:" "$VK_ICD_FILENAMES"

    echo
    print_banner "Vulkan info"
    vulkaninfo --summary 2>/dev/null | grep -E 'GPU|driver' || print_error "vulkaninfo failed :("

    echo
    print_banner "Launching vkcube, please wait..."
    vkcube >/dev/null 2>&1 &
    VKCUBE_PID=$!
    sleep 1.5
    if kill -0 "$VKCUBE_PID" 2>/dev/null; then
      RESULT=0
      kill "$VKCUBE_PID" 2>/dev/null
      sleep 0.3
      kill -9 "$VKCUBE_PID" 2>/dev/null || true
    else
      RESULT=1
    fi

    if [ "$RESULT" -eq 0 ]; then
      colorize2 "SUCCESS" "OK" "Vkcube loves you! -" "Vulkan is working! :)"
    else
      colorize2 "ERROR" "NC" "Vkcube is sad! -" "Vulkan seems broken :("
    fi
    print_warning "Press any key to continue..."
    read -n 1 -s
    exec ${refreshEnvScript}/bin/refresh-env
  '';
}

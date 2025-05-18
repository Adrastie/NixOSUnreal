{ pkgs, lib, utils }:

pkgs.writeScriptBin "vulkan-test-fhs" ''
  #!${pkgs.stdenv.shell}
  ${lib.banners.colorTheWorld}

  # Made for Nvidia only, maybe one day i will have an AMD gpu...
  print_banner "NVIDIA Driver Version"
  nvidia-smi --query-gpu=driver_version --format=csv,noheader 2>/dev/null || print_error "nvidia-smi not found or failed"
  echo
  print_banner "OpenGL Driver Paths"
  colorize2 "YELLOW" "NC" "OpenGL driver path:" "$(readlink -f /run/opengl-driver 2>/dev/null || print_error 'Not found')"
  colorize2 "YELLOW" "NC" "OpenGL driver-32bit path:" "$(readlink -f /run/opengl-driver-32 2>/dev/null || print_error 'Not found')"
  echo
  print_banner "Vulkan ICD Files"
  REAL_DRIVER_PATH=$(readlink -f /run/opengl-driver 2>/dev/null || echo "")

  if [ -n "$REAL_DRIVER_PATH" ] && [ -d "$REAL_DRIVER_PATH/share/vulkan/icd.d" ]; then
    find "$REAL_DRIVER_PATH/share/vulkan/icd.d" -name "*.json" 2>/dev/null
  else
    print_error "No Vulkan ICD files found"
  fi

  echo
  print_banner "NVIDIA GPU Information"
  lspci | grep -i nvidia
  echo
  print_banner "NVIDIA Devices"
  ls -la /dev/nvidia* 2>/dev/null || print_error "No NVIDIA devices found"

  echo
  print_banner "Checking Vulkan in FHS Environment"

  # GPU check
  detect_gpu_vendor() {
    if lspci | grep -i nvidia > /dev/null; then
      echo "nvidia"
    elif lspci | grep -i amd > /dev/null; then
      echo "amd"
    elif lspci | grep -i intel > /dev/null; then
      echo "intel"
    else
      echo "unknown"
    fi
  }

  GPU_VENDOR=$(detect_gpu_vendor)
  print_banner "Detected GPU vendor: $GPU_VENDOR"

  # Check Nvidia Vulkan ICD
  REAL_DRIVER_PATH=$(readlink -f /run/opengl-driver 2>/dev/null || echo "")
  if [ -n "$REAL_DRIVER_PATH" ] && [ -d "$REAL_DRIVER_PATH/share/vulkan/icd.d" ]; then
    if [ "$GPU_VENDOR" = "nvidia" ]; then
      NVIDIA_ICD="$REAL_DRIVER_PATH/share/vulkan/icd.d/nvidia_icd.x86_64.json"
      if [ -f "$NVIDIA_ICD" ]; then
        print_success "Using NVIDIA Vulkan ICD: $NVIDIA_ICD"
      fi
    fi
  fi

  print_banner "Environment variables"
  colorize2 "BYELLOW" "NC" "LD LIBRARY PATH:" "$LD_LIBRARY_PATH"
  colorize2 "BYELLOW" "NC" "VK ICD FILES:" "$VK_ICD_FILENAMES"
  echo
  print_banner "Vulkan info"
  vulkaninfo --summary 2>/dev/null | grep -E 'GPU|driver' || print_error "vulkaninfo failed :("

  # The cake is a lie :(
  echo
  print_banner "Launching vkcube, please wait..."
  vkcube >/dev/null 2>&1 &
  VKCUBE_PID=$!
  sleep 1.5
  if kill -0 $VKCUBE_PID 2>/dev/null; then
    RESULT=0
  else
    RESULT=1
  fi

  if kill -0 $VKCUBE_PID 2>/dev/null; then
    kill $VKCUBE_PID
    sleep 0.5
    kill -9 $VKCUBE_PID 2>/dev/null || true
  fi

  if [ $RESULT -eq 0 ]; then
    colorize2 "GREEN" "LGREEN"  "Vkcube loves you! -" "Vulkan is working! :)"
  else
    colorize2 "RED" "NC"  "Vkcube is sad! -" "Vulkan seem broken :("
  fi
  print_warning "Press any key to continue..."
  read -n 1 -s
  refresh-env
''
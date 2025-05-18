{ pkgs, lib }:

let
  pkgsModule = import ./pkgs.nix { inherit pkgs; };
  colors = import ../lib/colors.nix;
  dotnetPkg = pkgsModule.dotnetPkg;
  colorTheWorld = lib.banners.colorTheWorld;
in
{
  profile = ''
    ${colorTheWorld}
    # WIP, trying to support all gpu vendors, bit it will probably fail, sorry
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

    REAL_DRIVER_PATH=$(readlink -f /run/opengl-driver 2>/dev/null || echo "")
    REAL_DRIVER_32_PATH=$(readlink -f /run/opengl-driver-32 2>/dev/null || echo "")
    GPU_VENDOR=$(detect_gpu_vendor)
    print_banner "Detected GPU: $GPU_VENDOR"

    if [ -n "$REAL_DRIVER_PATH" ]; then
      export LD_LIBRARY_PATH="$REAL_DRIVER_PATH/lib:$LD_LIBRARY_PATH"
      if [ -d "$REAL_DRIVER_PATH/share/vulkan/icd.d" ]; then
        if [ "$GPU_VENDOR" = "nvidia" ]; then
          NVIDIA_ICD="$REAL_DRIVER_PATH/share/vulkan/icd.d/nvidia_icd.x86_64.json"
          if [ -f "$NVIDIA_ICD" ]; then
            export VK_ICD_FILENAMES="$NVIDIA_ICD"
            print_success "Using NVIDIA Vulkan ICD: $NVIDIA_ICD"
          else
            ICD_FILES=$(find "$REAL_DRIVER_PATH/share/vulkan/icd.d" -name "*.json" 2>/dev/null | tr '\n' ':' | sed 's/:$//')
            export VK_ICD_FILENAMES="$ICD_FILES"
            print_warning "NVIDIA ICD not found, using available ICDs: $VK_ICD_FILENAMES"
          fi
        else
          ICD_FILES=$(find "$REAL_DRIVER_PATH/share/vulkan/icd.d" -name "*.json" 2>/dev/null | tr '\n' ':' | sed 's/:$//')
          if [ -n "$ICD_FILES" ]; then
            export VK_ICD_FILENAMES="$ICD_FILES"
            print_success "Using Vulkan ICDs: $VK_ICD_FILENAMES"
          else
            print_error "No Vulkan ICD files found in $REAL_DRIVER_PATH/share/vulkan/icd.d :("
          fi
        fi
      else
        print_error "Vulkan ICD path not found: $REAL_DRIVER_PATH/share/vulkan/icd.d :("
      fi
    fi

    if [ -n "$REAL_DRIVER_32_PATH" ]; then
      export LD_LIBRARY_PATH="$REAL_DRIVER_32_PATH/lib:$LD_LIBRARY_PATH"
    fi

    case "$GPU_VENDOR" in
      nvidia)
        export __GLX_VENDOR_LIBRARY_NAME=nvidia
        export VK_ENABLE_RT=1
        ;;
      amd)
        export RADV_PERFTEST=aco
        unset __GLX_VENDOR_LIBRARY_NAME
        ;;
      intel)
        export INTEL_DEBUG=vs
        unset __GLX_VENDOR_LIBRARY_NAME
        ;;
      *)
        print_warning "Unknown GPU vendor detected. Trying mesa drivers."
        unset __GLX_VENDOR_LIBRARY_NAME
        ;;
    esac

    # Force X11
    export GDK_BACKEND=x11
    export QT_QPA_PLATFORM=xcb
    export SDL_VIDEODRIVER=x11

    # GLobal settings
    export FONTCONFIG_FILE=${pkgs.fontconfig.out}/etc/fonts/fonts.conf
    export LC_ALL=C.UTF-8
    export DOTNET_ROOT="${dotnetPkg}"
    export DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=1
    export PATH="${dotnetPkg}/bin:$PATH"

    # Workaround test
    export GTK_IM_MODULE=""
    export QT_IM_MODULE=""
    export XMODIFIERS=""

    # Trying to disable unreal ime
    export UE_DISABLE_SLATE_TEXTBOX_IME=1

    # Should avoid some issues
    export KDE_DEBUG=0
    export QT_X11_NO_MITSHM=1
    export _JAVA_AWT_WM_NONREPARENTING=1

    # Fix Unreal window focus issue?
    export QT_ACCESSIBILITY=1
    export UE_USE_WINDOW_FOCUS_MESSAGING=0
    export UE_DISABLE_FOCUS_RELOCATION=1

    # Unreal generic settings
    export UE_DISABLE_LINUX_CRASHREPORT_DIALOG=1
    export XDG_RUNTIME_DIR="/run/user/$(id -u)"

    # Performance test
    export MESA_GL_VERSION_OVERRIDE=4.5
    export __GL_SHADER_DISK_CACHE=1
    export __GL_SHADER_DISK_CACHE_PATH="$HOME/.cache/unreal-shaders"

    # Create shader cache folder if needed
    if [ ! -d "$HOME/.cache/unreal-shaders" ]; then
      mkdir -p "$HOME/.cache/unreal-shaders"
    fi

    # Additional test fixes
    export QT_PLUGIN_PATH=${pkgs.libsForQt5.qt5.qtbase}/lib/qt-${pkgs.libsForQt5.qt5.qtbase.version}/plugins
    export QML2_IMPORT_PATH=${pkgs.libsForQt5.qt5.qtbase}/lib/qt-${pkgs.libsForQt5.qt5.qtbase.version}/qml
    export VK_LAYER_PATH=${pkgs.vulkan-validation-layers}/share/vulkan/explicit_layer.d
  '';

  extraBwrapArgs = [
    "--dev-bind" "/dev" "/dev"
    "--dev-bind" "/sys" "/sys"
    "--dev-bind" "/proc" "/proc"
    "--bind" "/tmp" "/tmp"
    "--ro-bind" "/tmp/.X11-unix" "/tmp/.X11-unix"
    "--dev-bind" "/dev/dri" "/dev/dri"

    # NVIDIA
    "--dev-bind-try" "/dev/nvidia0" "/dev/nvidia0"
    "--dev-bind-try" "/dev/nvidiactl" "/dev/nvidiactl"
    "--dev-bind-try" "/dev/nvidia-modeset" "/dev/nvidia-modeset"
    "--dev-bind-try" "/dev/nvidia-uvm" "/dev/nvidia-uvm"
    "--dev-bind-try" "/dev/nvidia-uvm-tools" "/dev/nvidia-uvm-tools"

    # AMD/Intel GPU - Maybe?
    "--dev-bind-try" "/dev/kfd" "/dev/kfd"
    "--dev-bind-try" "/dev/dri/renderD128" "/dev/dri/renderD128"
  ];

  runScript = "bash";
}
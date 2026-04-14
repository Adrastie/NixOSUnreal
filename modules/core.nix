{ pkgs, lib, dotnetPkg }:

{
  profile = ''
    . ${lib.bashLib}/share/unreal/bash-lib.sh
    GPU_VENDOR=$(detect_gpu_vendor)
    print_banner "Detected GPU: $GPU_VENDOR"
    REAL_DRIVER_PATH=$(readlink -f /run/opengl-driver 2>/dev/null || echo "")
    REAL_DRIVER_32_PATH=$(readlink -f /run/opengl-driver-32 2>/dev/null || echo "")

    if [ -n "$REAL_DRIVER_PATH" ]; then
      export LD_LIBRARY_PATH="$REAL_DRIVER_PATH/lib''${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
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
          [ -n "$ICD_FILES" ] \
            && { export VK_ICD_FILENAMES="$ICD_FILES"; print_success "Using Vulkan ICDs: $VK_ICD_FILENAMES"; } \
            || print_error "No Vulkan ICD files found in $REAL_DRIVER_PATH/share/vulkan/icd.d"
        fi
      else
        print_error "Vulkan ICD path not found: $REAL_DRIVER_PATH/share/vulkan/icd.d"
      fi
    fi

    [ -n "$REAL_DRIVER_32_PATH" ] && \
      export LD_LIBRARY_PATH="$REAL_DRIVER_32_PATH/lib''${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"

    case "$GPU_VENDOR" in
      nvidia) export __GLX_VENDOR_LIBRARY_NAME=nvidia ;;
      *)      export __GLX_VENDOR_LIBRARY_NAME=mesa   ;;
    esac

    if [ "''${UE_VULKAN_DEBUG:-0}" = "1" ]; then
      export VK_LAYER_PATH=${pkgs.vulkan-validation-layers}/share/vulkan/explicit_layer.d
      print_warning "Vulkan validation layers ENABLED (UE_VULKAN_DEBUG=1)"
    fi

    # WORKAROUND: force X11
    export GDK_BACKEND=x11
    export QT_QPA_PLATFORM=xcb
    export SDL_VIDEODRIVER=x11

    # dotnet fix
    export FONTCONFIG_FILE=${pkgs.fontconfig.out}/etc/fonts/fonts.conf
    export LC_ALL=C.UTF-8
    export XDG_RUNTIME_DIR="/run/user/$(id -u)"
    export DOTNET_ROOT="${dotnetPkg}"
    export DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=1
    export PATH="${dotnetPkg}/bin:$PATH"

    # WORKAROUND: epic does not care about linux, so here are some settings that help
    export GTK_IM_MODULE=""
    export QT_IM_MODULE=""
    export XMODIFIERS=""
    export UE_DISABLE_SLATE_TEXTBOX_IME=1
    export KDE_DEBUG=0
    export QT_X11_NO_MITSHM=1
    export QT_ACCESSIBILITY=1
    export _JAVA_AWT_WM_NONREPARENTING=1
    export UE_DISABLE_LINUX_CRASHREPORT_DIALOG=1

    # Set MESA_GL version
    export MESA_GL_VERSION_OVERRIDE=4.5
    # Set shader disk cache to optimize shaders cache on restart
    export __GL_SHADER_DISK_CACHE=1
    export __GL_SHADER_DISK_CACHE_PATH="$HOME/.cache/unreal-shaders"
    mkdir -p "$HOME/.cache/unreal-shaders"
  '';

  extraBwrapArgs = [
    "--dev-bind" "/dev"  "/dev"
    "--dev-bind" "/sys"  "/sys"
    "--dev-bind" "/proc" "/proc"
    "--bind"     "/tmp"  "/tmp"
    "--ro-bind"  "/tmp/.X11-unix" "/tmp/.X11-unix"
    "--dev-bind-try" "/dev/nvidia0"          "/dev/nvidia0"
    "--dev-bind-try" "/dev/nvidiactl"        "/dev/nvidiactl"
    "--dev-bind-try" "/dev/nvidia-modeset"   "/dev/nvidia-modeset"
    "--dev-bind-try" "/dev/nvidia-uvm"       "/dev/nvidia-uvm"
    "--dev-bind-try" "/dev/nvidia-uvm-tools" "/dev/nvidia-uvm-tools"
    "--dev-bind-try" "/dev/kfd"            "/dev/kfd"
    "--dev-bind-try" "/dev/dri/renderD128" "/dev/dri/renderD128"
  ];
}

{ pkgs, lib }:

pkgs.writeShellApplication {
  name = "launch-unreal";
  checkPhase = ''bash -n "$target"'';
  bashOptions = [ "errexit" "pipefail" ];
  text = ''
    . ${lib.bashLib}/share/unreal/bash-lib.sh

    UE_ROOT=$(resolve_ue_root) || exit 1
    UE_BINARY_PATH=$(realpath "$UE_ROOT/Engine/Binaries/Linux/UnrealEditor")

    if [ ! -x "$UE_BINARY_PATH" ]; then
      print_error "$UE_BINARY_PATH is not executable"
      exit 1
    fi

    GPU_PREF=$(build_gpu_pref)
    OPT_FLAGS=$(build_opt_flags)

    if vulkaninfo --summary > /dev/null 2>&1; then
      print_success "Vulkan working: using Vulkan rendering"
      RENDER_OPTION="-vulkan"
    else
      print_warning "Vulkan unavailable: falling back to OpenGL"
      RENDER_OPTION="-opengl4"
    fi

    # UE_FIXED_ARGS and OPT_FLAGS are space-separated strings
    read -ra FIXED_ARGS_ARR <<< "''${UE_FIXED_ARGS:-}"
    read -ra OPT_FLAGS_ARR  <<< "''${OPT_FLAGS:-}"

    UE_LAUNCH_ARGS=("$RENDER_OPTION" "-AudioMixer")
    [[ -n "''${GPU_PREF:-}" ]] && UE_LAUNCH_ARGS+=("$GPU_PREF")
    [[ ''${#FIXED_ARGS_ARR[@]} -gt 0 ]] && UE_LAUNCH_ARGS+=("''${FIXED_ARGS_ARR[@]}")
    [[ ''${#OPT_FLAGS_ARR[@]}  -gt 0 ]] && UE_LAUNCH_ARGS+=("''${OPT_FLAGS_ARR[@]}")

    print_header "Launching UnrealEditor"
    print_base "  Binary: $UE_BINARY_PATH"
    print_base "  Flags:  ''${UE_LAUNCH_ARGS[*]}"
    [[ $# -gt 0 ]] && print_base "  Extra:  $*"

    cd "$UE_ROOT/Engine/Binaries/Linux"
    exec "./UnrealEditor" "''${UE_LAUNCH_ARGS[@]}" "$@"
  '';
}

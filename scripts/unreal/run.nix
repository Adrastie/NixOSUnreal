   { pkgs, lib, utils }:

   let
     unrealFHSWrapper = import ./fhs-wrapper.nix { inherit pkgs lib utils; };
   in

   pkgs.writeScriptBin "run-unreal" ''
     #!${pkgs.stdenv.shell}
     ${lib.banners.colorTheWorld}
     # Hardcoded default path :]
     DEFAULT_UE_PATH="../Engine/Binaries/Linux/UnrealEditor"
     clear
     # Set Unreal Binary Path
     if [ $# -ge 1 ] && [ -f "$1" ]; then
       UE_BINARY_PATH="$1"
       shift
     else
       UE_BINARY_PATH="$DEFAULT_UE_PATH"
     fi

     if [ ! -f "$UE_BINARY_PATH" ]; then
       print_error "Error: UnrealEditor binary not found at $UE_BINARY_PATH"
       print_warning "Please provide a valid path to the UnrealEditor binary"
       print_warning "If you are not using my folder structure you can add the path:"
       print_warning "run-unreal [/path/to/UnrealEditor] [args...]"
       exit 1
     fi

     if [ ! -x "$UE_BINARY_PATH" ]; then
       print_error "Error: $UE_BINARY_PATH is not executable"
       print_warning "Please set the binary execute permissions"
       print_warning "You can set it with: chmod +x $UE_BINARY_PATH"
       exit 1
     fi

     UE_BINARY_PATH=$(realpath "$UE_BINARY_PATH")
     UE_DIR=$(dirname "$UE_BINARY_PATH")
     UE_BIN=$(basename "$UE_BINARY_PATH")

     # Testing Vulkan using FHS environment
     print_banner "Testing Vulkan configuration..."
     if ! ${unrealFHSWrapper}/bin/unreal-fhs "vulkaninfo --summary > /dev/null 2>&1"; then
       print_error "Warning: Vulkan does not appear to be working :("
       print_warning "Falling back to OpenGL rendering :("
       RENDER_OPTION="-opengl4"
     else
       print_success "Vulkan seems to work, we will be using Vulkan rendering :)"
       RENDER_OPTION="-vulkan"
     fi

     # Trying to force X11 to fix popup issues
     FIXPARAM="-AllowStandaloneRenderThread=false"
     FIXPARAM="$FIXPARAM -ForceFrontendRenderThread"

     # Now we try to run Unreal Engine
     print_warning "Starting Unreal Engine Editor with $RENDER_OPTION"
     ${unrealFHSWrapper}/bin/unreal-fhs "cd '$UE_DIR' && ./'$UE_BIN' $RENDER_OPTION $FIXPARAM -nosplash -nocrashreportdialog $*"
   ''
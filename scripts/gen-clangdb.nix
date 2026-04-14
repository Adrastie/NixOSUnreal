{ pkgs, lib }:

pkgs.writeShellApplication {
  name = "gen-clangdb";
  checkPhase = ''bash -n "$target"'';
  bashOptions = [ "errexit" "pipefail" ];
  text = ''
    . ${lib.bashLib}/share/unreal/bash-lib.sh

    # NOTE: Binary build: project source only. Source build: full engine + project.
    # WARN: Must run inside unreal-fhs. Always pass an explicit path.

    if ! command -v dotnet &>/dev/null; then
      print_error "dotnet not found: must be run inside unreal-fhs:"
      print_base "  unreal-fhs"
      print_base "  gen-clangdb /path/to/MyProject.uproject"
      exit 1
    fi

    if [ $# -lt 1 ]; then
      print_error "Missing argument: path to .uproject"
      print_base "  gen-clangdb /path/to/MyProject.uproject"
      exit 1
    fi

    PROJECT=$(realpath "$1")

    if [ ! -f "$PROJECT" ]; then
      print_error "Not found: $PROJECT"
      exit 1
    fi

    PROJECT_DIR=$(dirname "$PROJECT")
    PROJECT_NAME=$(basename "$PROJECT" .uproject)

    # WARN: Blueprint-only projects have no .Target.cs
    if ! find "$PROJECT_DIR/Source" -name "*.Target.cs" 2>/dev/null | grep -q .; then
      print_error "$PROJECT_NAME is a Blueprint-only project? Missing Target.cs"
      exit 1
    fi

    UE_ROOT=$(resolve_ue_root) || exit 1
    UBT="$UE_ROOT/Engine/Binaries/DotNET/UnrealBuildTool/UnrealBuildTool.dll"

    if [ ! -f "$UBT" ]; then
      print_error "UnrealBuildTool not found: $UBT"
      print_base "For source builds you have to compile the engine first"
      exit 1
    fi

    TARGET="''${PROJECT_NAME}Editor"
    OUTPUT="$PROJECT_DIR/compile_commands.json"

    print_header "Generating compile_commands.json"
    print_base "  Target:  $TARGET (Development, Linux)"
    print_base "  Project: $PROJECT"
    print_base "  Output:  $OUTPUT"
    echo

    cd "$UE_ROOT"
    dotnet "$UBT" \
      -Mode=GenerateClangDatabase \
      -Project="$PROJECT" \
      "$TARGET" \
      Linux \
      Development \
      -OutputDir="$PROJECT_DIR"

    if [ -f "$OUTPUT" ]; then
      print_success "compile_commands.json generated :)"
      print_base "  Re-run after adding new source files or modules :/"
    else
      print_error "compile_commands.json was not created :( check UBT output"
      exit 1
    fi
  '';
}

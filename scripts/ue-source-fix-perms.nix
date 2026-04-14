# BUG: epic issue again, epic depot does not mark engine scripts and binaries executable... again, we are fixing it...
{ pkgs, lib }:

pkgs.writeShellApplication {
  name = "ue-source-fix-perms";
  runtimeInputs = [ pkgs.findutils pkgs.coreutils ];
  checkPhase = ''bash -n "$target"'';
  bashOptions = [ "errexit" "pipefail" ];
  text = ''
    . ${lib.bashLib}/share/unreal/bash-lib.sh


    UE_ROOT=$(resolve_ue_root) || exit 1
    print_header "Restoring execute permissions under $UE_ROOT"

    for f in \
      "$UE_ROOT/Setup.sh" \
      "$UE_ROOT/GenerateProjectFiles.sh" \
      "$UE_ROOT/Engine/Binaries/DotNET/GitDependencies/linux-x64/GitDependencies"; do
      if [ -f "$f" ]; then
        chmod +x "$f"
        colorize2 "SUCCESS" "NC" "  +x" "$f"
      fi
    done

    BUILD_SCRIPTS=$(find "$UE_ROOT/Engine/Build" -name "*.sh" 2>/dev/null || true)
    if [ -n "''${BUILD_SCRIPTS:-}" ]; then
      COUNT=$(echo "$BUILD_SCRIPTS" | wc -l)
      echo "$BUILD_SCRIPTS" | xargs -d $'\n' chmod +x
      print_success "Fixed $COUNT scripts under Engine/Build/"
    fi

    BIN_DIR="$UE_ROOT/Engine/Binaries/Linux"
    if [ -d "$BIN_DIR" ]; then
      BINS=$(find "$BIN_DIR" -maxdepth 1 -type f ! -name "*.debug" ! -name "*.sym" 2>/dev/null || true)
      if [ -n "''${BINS:-}" ]; then
        echo "$BINS" | xargs -d $'\n' chmod +x
        print_success "Fixed binaries in Engine/Binaries/Linux/"
      fi
    fi

    print_success "Done, you must re-run after every p4 sync"
  '';
}

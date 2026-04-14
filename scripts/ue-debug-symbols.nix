{ pkgs, lib }:

pkgs.writeShellApplication {
  name = "ue-debug-symbols";
  runtimeInputs = [ pkgs.findutils pkgs.coreutils ];
  checkPhase = ''bash -n "$target"'';
  bashOptions = [ "errexit" "pipefail" ];
  text = ''
    . ${lib.bashLib}/share/unreal/bash-lib.sh

    UE_ROOT=$(resolve_ue_root) || exit 1
    ENGINE_BIN="$UE_ROOT/Engine/Binaries/Linux"
    STASH_DIR="$ENGINE_BIN/debug-stash"

    ACTIVE=$(find "$ENGINE_BIN" -maxdepth 1 -name "*.debug" 2>/dev/null | wc -l)
    STASHED=$(find "$STASH_DIR" -maxdepth 1 -name "*.debug" 2>/dev/null | wc -l)

    print_header "Engine debug symbols: $ACTIVE active, $STASHED stashed"

    if [ "$ACTIVE" -gt 0 ]; then
      print_warning "Stashing $ACTIVE .debug files: LLDB will NOT load engine symbols!!!"
      mkdir -p "$STASH_DIR"
      mv "$ENGINE_BIN"/*.debug "$STASH_DIR/"
      print_success "Stashed, run again to restore"
    elif [ "$STASHED" -gt 0 ]; then
      print_warning "Restoring $STASHED .debug files: LLDB will load full engine symbols!!!"
      mv "$STASH_DIR"/*.debug "$ENGINE_BIN/"
      print_success "Restored!"
    else
      print_error "No .debug files found in either location"
      print_base "  Active:  $ENGINE_BIN/"
      print_base "  Stashed: $STASH_DIR/"
      exit 1
    fi
  '';
}

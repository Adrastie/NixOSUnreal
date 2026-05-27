{ pkgs, lib, unrealFHSWrapper }:

pkgs.writeShellApplication {
  name = "run-vscodium";
  checkPhase = ''bash -n "$target"'';
  bashOptions = [ "errexit" "pipefail" ];
  text = ''
    . ${lib.bashLib}/share/unreal/bash-lib.sh

    if [ -f "${pkgs.vscodium}/bin/codium" ]; then
      VSCODIUM_BIN="${pkgs.vscodium}/bin/codium"
    else
      print_error "VSCodium not found :("
      exit 1
    fi

    CMD=$(printf '%q ' "$VSCODIUM_BIN" "$@")
    exec ${unrealFHSWrapper}/bin/unreal-fhs "$CMD"
  '';
}

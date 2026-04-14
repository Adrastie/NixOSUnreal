{ pkgs, lib, unrealFHSWrapper }:

pkgs.writeShellApplication {
  name = "run-vscode";
  checkPhase = ''bash -n "$target"'';
  bashOptions = [ "errexit" "pipefail" ];
  text = ''
    . ${lib.bashLib}/share/unreal/bash-lib.sh

    if command -v code &>/dev/null; then
      VSCODE_BIN=$(command -v code)
    elif [ -f "${pkgs.vscode}/bin/code" ]; then
      VSCODE_BIN="${pkgs.vscode}/bin/code"
    else
      print_error "VSCode not found :("
      exit 1
    fi

    CMD=$(printf '%q ' "$VSCODE_BIN" "$@")
    exec ${unrealFHSWrapper}/bin/unreal-fhs "$CMD"
  '';
}

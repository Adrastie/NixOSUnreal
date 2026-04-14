{ pkgs, lib, unrealFHSWrapper }:

pkgs.writeShellApplication {
  name = "run-unreal";
  checkPhase = ''bash -n "$target"'';
  bashOptions = [ "errexit" "pipefail" ];
  text = ''
    . ${lib.bashLib}/share/unreal/bash-lib.sh
    clear

    ARGS=$(printf '%q ' "$@")
    exec ${unrealFHSWrapper}/bin/unreal-fhs "launch-unreal $ARGS"
  '';
}

{ pkgs, unrealFHS }:

pkgs.writeShellApplication {
  name = "unreal-fhs";
  text = ''
    if [ $# -eq 0 ]; then
      exec ${unrealFHS}/bin/unreal-env
    fi

    exec ${unrealFHS}/bin/unreal-env -c "$1"
  '';
}

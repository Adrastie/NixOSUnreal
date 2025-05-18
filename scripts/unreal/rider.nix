   { pkgs, lib, utils }:

   let
     unrealFHSWrapper = import ./fhs-wrapper.nix { inherit pkgs lib utils; };
   in

   pkgs.writeScriptBin "run-rider" ''
     #!${pkgs.stdenv.shell}
     ${lib.banners.colorTheWorld}
     TOOLBOX_RIDER="$HOME/.local/share/JetBrains/Toolbox/apps/rider/bin/rider.sh"

     if [ -f "$TOOLBOX_RIDER" ]; then
       ${unrealFHSWrapper}/bin/unreal-fhs "$TOOLBOX_RIDER $*"
     else
       ${unrealFHSWrapper}/bin/unreal-fhs "rider $*"
     fi
   ''
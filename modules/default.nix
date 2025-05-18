{ pkgs, lib, scripts }:

let
  pkgsModule = import ./pkgs.nix { inherit pkgs; };
  coreModule = import ./core.nix { inherit pkgs lib; };
  unrealFHS = import ./unreal-fhs.nix {
    inherit pkgs lib;
    dotnetPkg = pkgsModule.dotnetPkg;
  };
in {
  core = coreModule;
  inherit unrealFHS;
  inherit (scripts)
    vulkanDiagScript
    vulkanTestScript
    unrealFHSWrapper
    unrealScript
    riderScript
    kdeSettingsScript;
}
{ pkgs, lib, dotnetPkg }:

let
  pkgsModule = import ./pkgs.nix { inherit pkgs; };

  inherit (pkgsModule)
    debugTools audioTools gpuTools devTools vulkanStuff
    videoTools riderDev waylandStuff xorgStuff basicStuff;

  coreModule = import ./core.nix { inherit pkgs lib; };
in

pkgs.buildFHSEnv {
  name = "unreal-env";
  targetPkgs = _: (
    debugTools
    ++ audioTools
    ++ gpuTools
    ++ devTools
    ++ vulkanStuff
    ++ videoTools
    ++ riderDev
    ++ waylandStuff
    ++ xorgStuff
    ++ basicStuff
  );

  profile = coreModule.profile;
  extraBwrapArgs = coreModule.extraBwrapArgs;
  runScript = coreModule.runScript;
}
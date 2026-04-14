{ pkgs, lib, cfg ? {}, extraFHSPkgs ? [] }:

let
  pkgsModule = import ./pkgs.nix { inherit pkgs cfg; };

  inherit (pkgsModule)
    debugTools audioTools gpuTools devTools vulkanStuff
    videoTools ideTools waylandStuff xorgStuff basicStuff toolboxLibs;

  coreModule = import ./core.nix { inherit pkgs lib; dotnetPkg = pkgsModule.dotnetPkg; };
in
{
  unrealFHS = pkgs.buildFHSEnv {
    name = "unreal-env";
    targetPkgs = _: (
      debugTools
      ++ audioTools
      ++ gpuTools
      ++ devTools
      ++ vulkanStuff
      ++ videoTools
      ++ ideTools
      ++ waylandStuff
      ++ xorgStuff
      ++ basicStuff
      ++ toolboxLibs
      ++ extraFHSPkgs
    );

    profile        = coreModule.profile;
    extraBwrapArgs = coreModule.extraBwrapArgs;
    runScript      = "bash";
  };
}

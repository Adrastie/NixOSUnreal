{ pkgs, lib }:

let
  utils = import ./lib/utils.nix { inherit pkgs lib; };
  killUnrealScript = import ./unreal/kill.nix { inherit pkgs lib utils; };
  refreshEnvScript = import ./refresh-env.nix { inherit pkgs lib utils; };
  vulkanTestScript = import ./vulkan/test.nix { inherit pkgs lib utils; };
  vulkanDiagScript = import ./vulkan/diag.nix { inherit pkgs lib utils; };
  unrealFHSWrapper = import ./unreal/fhs-wrapper.nix { inherit pkgs lib utils; };
  unrealScript = import ./unreal/run.nix { inherit pkgs lib utils; };
  riderScript = import ./unreal/rider.nix { inherit pkgs lib utils; };
  kdeSettingsScript = import ./unreal/kde-settings.nix { inherit pkgs lib utils; };
in {
  inherit
    killUnrealScript
    refreshEnvScript
    vulkanTestScript
    vulkanDiagScript
    unrealFHSWrapper
    unrealScript
    riderScript
    kdeSettingsScript;
}
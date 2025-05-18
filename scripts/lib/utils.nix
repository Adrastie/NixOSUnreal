{ pkgs, lib }:

let
  colors = lib.colors;
  colorTheWorld = lib.banners.colorTheWorld;
  unreal_process_pattern = "UnrealEditor|UE5Editor";
in {
  inherit unreal_process_pattern;

  setupScriptEnv = ''
    ${colorTheWorld}
    UNREAL_PROCESS_PATTERN="${unreal_process_pattern}"
  '';
}
{ pkgs, lib, unrealFHS, cfg ? {} }:

let
  refreshEnvScript    = import ./refresh-env.nix        { inherit pkgs lib; };
  unrealFHSWrapper    = import ./unreal-fhs.nix         { inherit pkgs unrealFHS; };
  vulkanTestScript    = import ./vulkan-test.nix        { inherit pkgs lib refreshEnvScript; };
  runUnrealScript     = import ./run-unreal.nix         { inherit pkgs lib unrealFHSWrapper; };
  checkVulkanScript   = import ./check-vulkan.nix       { inherit pkgs unrealFHSWrapper vulkanTestScript; };
  killUnrealScript    = import ./kill-unreal.nix        { inherit pkgs lib; };
  debugSymbolsScript  = import ./ue-debug-symbols.nix  { inherit pkgs lib; };
  genClangdbScript    = import ./gen-clangdb.nix        { inherit pkgs lib; };

  runRiderScript   = if cfg.enableRider  or true then import ./run-rider.nix           { inherit pkgs lib unrealFHSWrapper; } else null;
  runVscodeScript  = if cfg.enableVscode or true then import ./run-vscode.nix          { inherit pkgs lib unrealFHSWrapper; } else null;
  p4FixPermsScript = if cfg.enableP4     or true then import ./ue-source-fix-perms.nix { inherit pkgs lib; }                  else null;

  ideScripts = []
    ++ (if runRiderScript   != null then [ runRiderScript   ] else [])
    ++ (if runVscodeScript  != null then [ runVscodeScript  ] else [])
    ++ (if p4FixPermsScript != null then [ p4FixPermsScript ] else []);
in {
  inherit
    refreshEnvScript
    unrealFHSWrapper
    vulkanTestScript
    runUnrealScript
    checkVulkanScript
    killUnrealScript
    debugSymbolsScript
    genClangdbScript
    runRiderScript
    runVscodeScript
    p4FixPermsScript;

  all = [
    refreshEnvScript
    unrealFHSWrapper
    vulkanTestScript
    runUnrealScript
    checkVulkanScript
    killUnrealScript
    debugSymbolsScript
    genClangdbScript
  ] ++ ideScripts;
}

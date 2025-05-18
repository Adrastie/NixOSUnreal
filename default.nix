{ pkgs ? import <nixpkgs> { config.allowUnfree = true; } }:

let
  lib = import ./lib { inherit pkgs; };
  scripts = import ./scripts { inherit pkgs lib; };
  modules = import ./modules { inherit pkgs lib scripts; };
in {
  inherit lib scripts modules;

  unrealFHS = modules.unrealFHS;
  killUnrealScript = scripts.killUnrealScript;
  default = modules.unrealFHS;
}
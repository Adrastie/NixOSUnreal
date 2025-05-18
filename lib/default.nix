{ pkgs }:

{
  colors = import ./colors.nix;
  banners = import ./banners.nix { inherit pkgs; colors = import ./colors.nix; };
}
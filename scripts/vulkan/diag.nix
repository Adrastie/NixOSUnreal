{ pkgs, lib, utils }:

pkgs.writeScriptBin "check-vulkan" ''
  #!${pkgs.stdenv.shell}
  ${lib.banners.colorTheWorld}
  clear

  # Nvidia only for now
  if command -v unreal-fhs &>/dev/null; then
    unreal-fhs vulkan-test-fhs
  else
    print_error "unreal-fhs command not found. Cannot run Vulkan test in FHS environment."
  fi
''
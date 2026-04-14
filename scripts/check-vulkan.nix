{ pkgs, unrealFHSWrapper, vulkanTestScript }:

pkgs.writeShellApplication {
  name = "check-vulkan";
  text = ''
    exec ${unrealFHSWrapper}/bin/unreal-fhs "${vulkanTestScript}/bin/vulkan-test-fhs"
  '';
}

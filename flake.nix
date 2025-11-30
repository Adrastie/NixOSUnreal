{
  description = "Adrastie Unreal Engine 5 Binary NixOS FHS Dev Env";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };

      lib = import ./lib { inherit pkgs; };
      scripts = import ./scripts { inherit pkgs lib; };
      modules = import ./modules { inherit pkgs lib scripts; };
    in {
      packages.${system} = {
        unrealFHS = modules.unrealFHS;
        killUnrealScript = scripts.killUnrealScript;
        default = modules.unrealFHS;
      };

devShells.${system}.default = pkgs.mkShell {
  buildInputs = [
    modules.unrealFHS
    scripts.vulkanTestScript
    scripts.vulkanDiagScript
    scripts.unrealFHSWrapper
    scripts.unrealScript
    scripts.riderScript
    scripts.kdeSettingsScript
    scripts.killUnrealScript
    scripts.refreshEnvScript
  ];

  shellHook = ''
    export PATH="${modules.unrealFHS}/bin:$PATH"
    ${scripts.refreshEnvScript}/bin/refresh-env
  '';
};
};
}

{
  description = "Adrastie NixOS FHS Dev Env for Unreal Engine 5.6/5.7";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }:
    let
      system    = "x86_64-linux";
      pkgs      = import nixpkgs { inherit system; config.allowUnfree = true; };
      userConfig = if builtins.pathExists ./user-config.nix then import ./user-config.nix else {};
      cfg = {
        enableRider  = userConfig.enableRider  or true;
        enableVscode = userConfig.enableVscode or true;
        enableGit    = userConfig.enableGit    or true;
        enableP4     = userConfig.enableP4     or true;
      };

      lib    = import ./lib { inherit pkgs; };
      launchUnrealScript = import ./scripts/launch-unreal.nix { inherit pkgs lib; };
      modules = import ./modules { inherit pkgs lib cfg; extraFHSPkgs = [ launchUnrealScript ]; };
      scripts = import ./scripts { inherit pkgs lib cfg; unrealFHS = modules.unrealFHS; };

    in {
      packages.${system}.default = modules.unrealFHS;
      apps.${system} = {
        default      = { type = "app"; program = "${scripts.runUnrealScript}/bin/run-unreal"; };
        run-unreal   = { type = "app"; program = "${scripts.runUnrealScript}/bin/run-unreal"; };
        check-vulkan        = { type = "app"; program = "${scripts.checkVulkanScript}/bin/check-vulkan"; };
        kill-unreal         = { type = "app"; program = "${scripts.killUnrealScript}/bin/kill-unreal"; };
        ue-debug-symbols    = { type = "app"; program = "${scripts.debugSymbolsScript}/bin/ue-debug-symbols"; };
        gen-clangdb         = { type = "app"; program = "${scripts.genClangdbScript}/bin/gen-clangdb"; };
      }
      // (if cfg.enableRider  then { run-rider          = { type = "app"; program = "${scripts.runRiderScript}/bin/run-rider"; };                } else {})
      // (if cfg.enableVscode then { run-vscode         = { type = "app"; program = "${scripts.runVscodeScript}/bin/run-vscode"; };               } else {})
      // (if cfg.enableP4     then { ue-source-fix-perms = { type = "app"; program = "${scripts.p4FixPermsScript}/bin/ue-source-fix-perms"; }; } else {});

      devShells.${system}.default = pkgs.mkShell {
        packages = [
          modules.unrealFHS
        ]
        ++ scripts.all
        ++ (if cfg.enableRider then [ pkgs.jetbrains-toolbox ] else []);

        shellHook = ''
          # NOTE: source .envrc-user if direnv didnt, direnv sets $DIRENV_DIR when active.
          # TESTING: so... fixed for now? it should skip if present
          if [ -z "''${DIRENV_DIR:-}" ] && [ -f "$PWD/.envrc-user" ]; then
            # shellcheck source=/dev/null
            source "$PWD/.envrc-user"
          fi
          ${scripts.refreshEnvScript}/bin/refresh-env
        '';
      };
    };
}

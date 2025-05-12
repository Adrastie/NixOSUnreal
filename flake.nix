{
  description = "My Unreal Engine 5 Binary NixOS FHS Dev Env";

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

      # DotnetPkg version
      dotnetPkg = with pkgs.dotnetCorePackages; combinePackages [
        sdk_8_0
      ];

      unrealFHS = pkgs.buildFHSEnv {
        name = "unreal-env";
        targetPkgs = pkgs: (with pkgs; [
          # Basic stuff
          bash
          coreutils
          # UDEV stuff
          udev
          systemd
          eudev
          # Mandatory Unreal libs
          cairo
          curl
          dbus
          fontconfig
          freetype
          glib
          gnumake
          icu
          libGL
          libGLU
          pulseaudio
          libuuid
          mesa
          nspr
          nss
          openssl
          pango
          python3
          vulkan-loader
          # SDL
          SDL2
          SDL2_image
          SDL2_mixer
          SDL2_ttf
          # Devtools
          cmake
          git
          perl
          pkg-config
          # C++
          clang_16
          llvmPackages_16.libcxx
          lld_16
          # .NET/Rider
          dotnetPkg
          mono
          jetbrains.rider
          # Additional stuff for Rider
          zlib
          jdk
          # Mandatory xorg stuff to make it work on wayland
          ]) ++ (with pkgs.xorg; [
              libICE
              libSM
              libX11
              libxcb
              libXcomposite
              libXcursor
              libXdamage
              libXext
              libXfixes
              libXi
              libXrandr
              libXrender
              libXScrnSaver
              libxshmfence
              libXtst
          ]);

        profile = ''
          export VK_LAYER_PATH=${pkgs.vulkan-validation-layers}/share/vulkan/explicit_layer.d
          export FONTCONFIG_FILE=${pkgs.fontconfig.out}/etc/fonts/fonts.conf
          export SDL_VIDEODRIVER=x11
          export LC_ALL=C.UTF-8
          export DOTNET_ROOT="${dotnetPkg}"
          export DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=1
          export PATH="${dotnetPkg}/bin:$PATH"
        '';

        extraBwrapArgs = [
          "--dev-bind /dev /dev"
          "--dev-bind /sys /sys"
          "--dev-bind /proc /proc"
        ];

        runScript = "bash";
      };

      # Wrapper
      unrealScript = pkgs.writeScriptBin "run-unreal" ''
        #!${pkgs.stdenv.shell}
        DEFAULT_UE_PATH="../Engine/Binaries/Linux/UnrealEditor"

        if [ $# -ge 1 ]; then
          UE_BINARY_PATH="$1"
          shift
        else
          UE_BINARY_PATH="$DEFAULT_UE_PATH"
        fi

        if [ ! -f "$UE_BINARY_PATH" ]; then
          echo "Error: Binary not found at $UE_BINARY_PATH"
          echo "Please provide a valid path to the UnrealEditor binary"
          echo "Usage: run-unreal [/path/to/UnrealEditor] [args...]"
          exit 1
        fi

        if [ ! -x "$UE_BINARY_PATH" ]; then
          echo "Error: $UE_BINARY_PATH is not executable"
          echo "Please ensure the binary has execute permissions"
          echo "You can add them with: chmod +x $UE_BINARY_PATH"
          exit 1
        fi
        UE_BINARY_PATH=$(realpath "$UE_BINARY_PATH")
        UE_DIR=$(dirname "$UE_BINARY_PATH")
        UE_BIN=$(basename "$UE_BINARY_PATH")
        ${unrealFHS}/bin/unreal-env -c "cd '$UE_DIR' && ./'$UE_BIN' $*"
      '';

      riderScript = pkgs.writeScriptBin "run-rider" ''
        #!${pkgs.stdenv.shell}
        TOOLBOX_RIDER="$HOME/.local/share/JetBrains/Toolbox/apps/rider/bin/rider.sh"

        if [ -f "$TOOLBOX_RIDER" ]; then
          ${unrealFHS}/bin/unreal-env -c "$TOOLBOX_RIDER $*"
        else
          ${unrealFHS}/bin/unreal-env -c "rider $*"
        fi
      '';

    in {
      packages.${system} = {
        default = unrealFHS;
        unrealRunner = unrealScript;
        riderRunner = riderScript;
      };

      devShells.${system}.default = pkgs.mkShell {
        buildInputs = [
          unrealFHS
          unrealScript
          riderScript
        ];

        shellHook = ''
          echo "NixOS Unreal Engine 5 Binary Development Environment"
          echo ""
          echo "To run Unreal Engine:"
          echo "  run-unreal [optional_path] [args...]"
          echo ""
          echo "  - Default path: ../Engine/Binaries/Linux/UnrealEditor"
          echo "  - If you specify a path, it will be used instead"
          echo ""
          echo "If you use Rider, run it first then start Unreal through your Rider Project."
          echo "To run Rider IDE within the environment:"
          echo "  run-rider [args...]"
          echo ""
          echo "To enter the FHS shell:"
          echo "  unreal-env"
        '';
      };
    };
}
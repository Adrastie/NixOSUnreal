{ pkgs, lib, unrealFHSWrapper }:

pkgs.writeShellApplication {
  name = "run-rider";
  runtimeInputs = [ pkgs.findutils ];
  checkPhase = ''bash -n "$target"'';
  bashOptions = [ "errexit" "pipefail" ];
  text = ''
    . ${lib.bashLib}/share/unreal/bash-lib.sh

    RIDER_BIN=""

    if [ -n "''${RIDER_PATH:-}" ] && [ -f "$RIDER_PATH" ]; then
      RIDER_BIN="$RIDER_PATH"
    else
      TOOLBOX_APPS="$HOME/.local/share/JetBrains/Toolbox/apps"
      if [ -d "$TOOLBOX_APPS" ]; then
        # Toolbox used to install "rider.sh"; newer versions install "rider" (no extension)
        RIDER_BIN=$(find "$TOOLBOX_APPS" -maxdepth 3 \
          \( -name "rider" -o -name "rider.sh" \) -path "*/bin/*" \
          2>/dev/null | sort -V | tail -1) || RIDER_BIN=""
      fi
    fi

    if [ -n "''${RIDER_BIN:-}" ] && [ -f "$RIDER_BIN" ]; then
      print_success "Launching Rider: $RIDER_BIN"
      CMD=$(printf '%q ' "$RIDER_BIN" "$@")
      exec ${unrealFHSWrapper}/bin/unreal-fhs "$CMD"
    fi

    TOOLBOX_BIN="${pkgs.jetbrains-toolbox}/bin/jetbrains-toolbox"
    if [ -f "$TOOLBOX_BIN" ]; then
      print_warning "Rider not found -- launching Toolbox to install it."
      print_base "  To skip discovery, set RIDER_PATH in .envrc-user."
      exec "$TOOLBOX_BIN"
    fi

    print_error "Rider not found and Toolbox is not available."
    print_base "  Set RIDER_PATH=/path/to/rider.sh in .envrc-user"
    print_base "  or install Rider via JetBrains Toolbox."
    exit 1
  '';
}

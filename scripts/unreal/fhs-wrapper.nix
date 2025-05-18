{ pkgs, lib, utils }:

pkgs.writeScriptBin "unreal-fhs" ''
  #!${pkgs.stdenv.shell}
  ${lib.banners.colorTheWorld}
  clear
  if [ $# -eq 0 ]; then
    unreal-env
  else
    TEMP_SCRIPT=$(mktemp)
    trap 'rm -f "$TEMP_SCRIPT"' EXIT
    chmod +x "$TEMP_SCRIPT"
    {
      echo '#!/bin/bash'
      echo 'set -e'
      for arg in "$@"; do
        printf '%s\n' "''${arg}"
      done
    } > "$TEMP_SCRIPT"

    unreal-env "$TEMP_SCRIPT"
    result=$?
    echo
    exit $result
  fi
''
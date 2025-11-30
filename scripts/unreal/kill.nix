{ pkgs, lib, utils }:

let
  findProcess = import ./find-process.nix { inherit pkgs lib utils; };
  cleanup = import ./cleanup.nix { inherit pkgs lib utils; };
  gpuCheck = import ./gpu-check.nix { inherit pkgs lib utils; };
  netCheck = import ./net-check.nix { inherit pkgs lib utils; };
in

pkgs.writeScriptBin "kill-unreal" ''
  #!${pkgs.stdenv.shell}
  ${utils.setupScriptEnv}
  clear
  print_banner "Unreal Engine Killer & GPU Reset tool"

  ${findProcess}
  ${cleanup}
  ${gpuCheck}
  ${netCheck}

  # Main
  find_and_kill_unreal
  cleanup_temp_files
  check_gpu_memory
  check_network_connections

  echo
  print_banner "Job done, target destroyed!"
  print_warning "Press any key to exit..."
  read -n 1 -s
''

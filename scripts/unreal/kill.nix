{ pkgs, lib, utils }:

let
  findProcess = import ./find-process.nix { inherit pkgs lib utils; };
  cleanup = import ./cleanup.nix { inherit pkgs lib utils; };
  gpuCheck = import ./gpu-check.nix { inherit pkgs lib utils; };
  netCheck = import ./net-check.nix { inherit pkgs lib utils; };
  emergency = import ./emergency.nix { inherit pkgs lib utils; };
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
  ${emergency}

  # Main
  find_and_kill_unreal
  cleanup_temp_files
  check_gpu_memory
  check_network_connections

  echo
  print_error "If everything else failed i can make an emergency script."
  print_error "If you intend to run the SAVE YOUR WORK!!! Do you want that? [y/N]"
  read -n 1 -r response
  echo

  if [[ "$response" =~ ^[Yy]$ ]]; then
    create_emergency_script
  else
    print_info "Cancelled. Ultimate Unreal Killer will stay hidden for now."
  fi

  echo
  print_banner "Job done, target destroyed!"
  print_warning "Press any key to exit..."
  read -n 1 -s
''
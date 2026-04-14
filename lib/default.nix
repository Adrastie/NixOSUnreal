{ pkgs }:

{
  bashLib = pkgs.writeTextFile {
    name        = "unreal-bash-lib";
    destination = "/share/unreal/bash-lib.sh";
    text = ''
      ERROR="\\033[0;31m"
      ACCENT="\\033[1;31m"
      WARNING="\\033[1;33m"
      LABEL="\\033[0;33m"
      SUCCESS="\\033[0;32m"
      OK="\\033[1;32m"
      HEADER="\\033[1;34m"
      FRAME="\\033[1;37m"
      NC="\\033[0m"

      colorize2() {
        local c1="$1" c2="$2" t1="$3" t2="$4"
        echo -e "''${!c1}$t1''${NC} ''${!c2}$t2''${NC}"
      }
      print_header()  { echo -e "''${LABEL}===== $1 =====''${NC}" >&2; }
      print_banner()  { echo -e "''${FRAME}======================== ''${ACCENT}<3<3<3''${NC}''${LABEL} $1 ''${NC}''${ACCENT}<3<3<3''${NC}''${FRAME}========================''${NC}" >&2; }
      print_success() { echo -e "''${SUCCESS}$1''${NC}" >&2; }
      print_error()   { echo -e "''${ERROR}$1''${NC}" >&2; }
      print_warning() { echo -e "''${WARNING}$1''${NC}" >&2; }
      print_base()    { echo -e "''${NC}$1''${NC}" >&2; }
      print_info()    { echo -e "''${WARNING}[!]''${NC} $1 ''${WARNING}[!]''${NC}" >&2; }

      UNREAL_PROCESS_PATTERN="UnrealEditor|UE5Editor"

      find_ue_procs() {
        ps aux | grep -E "$UNREAL_PROCESS_PATTERN" | grep -v grep | grep -v "kill-unreal" || true
      }

      resolve_ue_root() {
        local rel="Engine/Binaries/Linux/UnrealEditor"
        if [ -n "''${UE_PATH:-}" ] && [ -f "$UE_PATH/$rel" ]; then
          echo "$UE_PATH"
        elif [ -f "$PWD/../$rel" ]; then
          echo "$(realpath "$PWD/..")"
        elif [ -f "$PWD/$rel" ]; then
          echo "$(realpath "$PWD")"
        else
          print_error "Unreal Engine root not found :("
          print_base "Configured in your .envrc-user OR as env var: export UE_PATH=/path/to/UnrealEngine"
          return 1
        fi
      }

      detect_gpu_vendor() {
        if ${pkgs.pciutils}/bin/lspci | grep -qi nvidia; then echo "nvidia"
        elif ${pkgs.pciutils}/bin/lspci | grep -qiE "amd|ati|radeon"; then echo "amd"
        elif ${pkgs.pciutils}/bin/lspci | grep -qi intel; then echo "intel"
        else echo "unknown gpu? weird!"
        fi
      }

      build_gpu_pref() {
        case "$(detect_gpu_vendor)" in
          nvidia) echo "-preferNvidia" ;;
          amd)    echo "-preferAMD"    ;;
          intel)  echo "-preferIntel"  ;;
          *)      echo ""              ;;
        esac
      }

      build_opt_flags() {
        local flags=""

        # -vulkandebug:
        [ "''${UE_VULKAN_DEBUG:-0}"      = "1" ] && flags="$flags -vulkandebug"

        # -norelativemousemode:
        [ "''${UE_NO_RELATIVE_MOUSE:-0}" = "1" ] && flags="$flags -norelativemousemode"

        # -gpucrashdebugging:
        [ "''${UE_GPU_CRASH_DEBUG:-0}"   = "1" ] && flags="$flags -gpucrashdebugging"

        # -stompmalloc:
        [ "''${UE_STOMP_MALLOC:-0}"      = "1" ] && flags="$flags -stompmalloc"

        # -ansimalloc:
        [ "''${UE_ANSI_MALLOC:-0}"       = "1" ] && [ "''${UE_STOMP_MALLOC:-0}" != "1" ] && flags="$flags -ansimalloc"

        echo "$flags"
      }
    '';
  };
}

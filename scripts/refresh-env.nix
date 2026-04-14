{ pkgs, lib }:

pkgs.writeShellApplication {
  name = "refresh-env";
  checkPhase = ''bash -n "$target"'';
  bashOptions = [ "errexit" "pipefail" ];
  text = ''
    . ${lib.bashLib}/share/unreal/bash-lib.sh
    clear

    G="''${OK}"      # frame
    B="''${HEADER}"  # section
    Y="''${WARNING}" # command
    D="''${SUCCESS}" # desc
    H="''${ACCENT}"  # red
    T="''${LABEL}"   # title
    R="''${NC}"      # reset

    echo -e "$G╔══''${R}LOVE''${H}♥''${R}IS''${H}♥''${R}LOVE''${G}══════════════════════════════════════════════════════════════════════╗$R"
    echo -e "$G║            ''${H}♥♥♥♥♥♥''${R} Adrastie NixOS Unreal Engine 5 Dev Env ''${H}♥♥♥♥♥♥''${G}                    ║$R"
    echo -e "$G╠════════════════════════════════════════════════════════════════════════════════════╣$R"
    echo -e "$G║$R                                                                                    $G║$R"
    echo -e "$G║$R  $B[nix run]$R                                                                         $G║$R"
    echo -e "$G║$R    $Y nix run .$R                         $D: launch Unreal Editor                      $R $G║$R"
    echo -e "$G║$R    $Y nix run .#run-rider$R               $D: (optional) JetBrains Rider                $R $G║$R"
    echo -e "$G║$R    $Y nix run .#run-vscode$R              $D: (optional) Visual Studio Code             $R $G║$R"
    echo -e "$G║$R    $Y nix run .#check-vulkan$R            $D: Vulkan diagnostics                        $R $G║$R"
    echo -e "$G║$R    $Y nix run .#kill-unreal$R             $D: kill UE processes + cache info            $R $G║$R"
    echo -e "$G║$R    $Y nix run .#ue-debug-symbols$R        $D: stash/restore engine .debug files         $R $G║$R"
    echo -e "$G║$R    $Y nix run .#gen-clangdb$R             $D: generate compile_commands.json            $R $G║$R"
    echo -e "$G║$R    $Y nix run .#ue-source-fix-perms$R     $D: (optional) Fix UE source +x after p4 sync $R $G║$R"
    echo -e "$G║$R                                                                                    $G║$R"
    echo -e "$G║$R  $B[nix-direnv & nix develop]$R  $D all commands available on PATH$R                       $G║$R"
    echo -e "$G║$R    $Y run-unreal$R [args]             $Y run-rider$R [args]                                $G║$R"
    echo -e "$G║$R    $Y run-vscode$R [args]             $Y check-vulkan$R $D: Vulkan diagnostic$R                $G║$R"
    echo -e "$G║$R    $Y kill-unreal$R                   $Y unreal-fhs$R $D: enter env FHS sandbox$R              $G║$R"
    echo -e "$G║$R    $Y ue-debug-symbols$R               $D: stash/restore .debug files (LLDB RAM)$R         $G║$R"
    echo -e "$G║$R    $Y gen-clangdb$R [project.uproject] $D: generate compile_commands.json                $G║$R"
    echo -e "$G║$R    $Y ue-source-fix-perms$R            $D: restore +x bits after p4 sync (UE source)$R     $G║$R"
    echo -e "$G║$R                                                                                    $G║$R"
    echo -e "$G║$R  $B[.envrc-user] $D set mandatory paths OR set as env var:$R                             $G║$R"
    echo -e "$G║$R    $Y UE_PATH$R         $D: active engine root (used by all scripts)$R                     $G║$R"
    echo -e "$G║$R    $Y RIDER_PATH$R      $D: override Toolbox Rider binary discovery$R                      $G║$R"
    echo -e "$G║$R                                                                                    $G║$R"
    echo -e "$G║$R  $B[opt flags]$D uncomment in .envrc-user or export before running$R                     $G║$R"
    echo -e "$G║$R    $Y UE_VULKAN_DEBUG=1$R       $D: Vulkan validation layers$R                             $G║$R"
    echo -e "$G║$R    $Y UE_NO_RELATIVE_MOUSE=1$R  $D: fix SDL mouse grab on Xwayland / remote desktop$R      $G║$R"
    echo -e "$G║$R    $Y UE_GPU_CRASH_DEBUG=1$R    $D: GPU crash dump$R                                       $G║$R"
    echo -e "$G║$R    $Y UE_STOMP_MALLOC=1$R       $D: guard-page allocator$R                                 $G║$R"
    echo -e "$G║$R    $Y UE_ANSI_MALLOC=1$R        $D: system malloc for valgrind$R                           $G║$R"
    echo -e "$G║$R                                                                                    $G║$R"
    echo -e "$G║$R  $B[UE 5.7 SDL3 XWayland popup fix]$R $D: menus appear at wrong position without this$R    $G║$R"
    echo -e "$G║$R    add to $Y UE_FIXED_ARGS$R $D(in .envrc-user, set W/H to primary monitor resolution):$R  $G║$R"
    echo -e "$G║$R    $Y -windowed -ResX=W -ResY=H -nohighdpi$R                                           $G║$R"
    echo -e "$G║$R                                                                                    $G║$R"
    echo -e "$G╚════════════════════════════════════════════════════════════════''${R}MAKE''${H}♥''${R}GAMES''${H}♥''${R}NOT''${H}♥''${R}WAR''${G}══╝$R"
    echo
  '';
}

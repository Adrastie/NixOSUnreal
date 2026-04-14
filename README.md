# Adrastie NixOS Unreal Dev Env 2026 update :)

NixOS FHS environment for Unreal Engine 5.

Should work on any UE5 version but i'm only focusing 5.6 and 5.7 right now.

---

### Breaking bug on UE 5.7, mouse input with SDL3:

UE 5.7 now use SDL3 which has known input issues on Linux under Wayland/XWayland.
`.envrc-user` already apply all available workarounds BUT not everything can be done this way.

What remains:

**Source builds have issues that does not exist with the Epic binary.**
As usual epic does not care about linux, this issue is almost a year old... https://forums.unrealengine.com/t/unreal-editor-5-7-ui-interaction-is-broken-on-linux-for-3-month-already/2652325/58 .

And it will not get any better with the massive epic layoffs.

Workaround on KDE:

**KDE: add a Window Rule** (System Settings → Window Management → Window Rules):
- Window class: `UnrealEditor`
- Focus stealing prevention: `Force` / `Extreme`
- Focus protection: `Force` / `None`
- Accept focus: `Force` / `No`

This workaround require KWin 6.5.4 or newer.

WARN: YOU MUST Edit `.envrc-user` and set **`-ResX`/`-ResY` in `UE_FIXED_ARGS`** TO MATCH YOUR PRIMARY MONITOR RESOLUTION.

## Usage:

Clone the repo, set `UE_PATH` in `.envrc-user` to your Unreal Engine root folder.
You can configure multiples Unreal Engine version in the .envrc-user for quick switch through env var.

```bash
git clone https://github.com/Adrastie/NixOSUnreal.git
cd NixOSUnreal
vim .envrc-user
# (optional) set multiples Unreal Engine version path
# (recommanded) set UE default version path or set the UE_PATH env var
UE_PATH=/absolute/path/to/UnrealEngine
```

## Tree structure:

Important: If you are putting folders inside this project folders, such as the following workflow YOU MUST PUT THE FOLDER IN YOUR .gitignore

Why? As nix flakes copy their source directory to the store as the flake is at the folders root everything inside, including any of your folders gets included.

Luckily for us nix flakes respect .gitignore, if you do not want to use a git repo you can still fallback to the previous "nix develop" folder without nesting.

---

## Tree workflow:

All three workflow are compatible with each others, they can even be used simultaneously!

Note: all commands and flags are listed on entry (or run `refresh-env`) EVEN THE DISABLED ONE!

### 1. direnv, or the magic of auto-activation :)

My daily workflow, aka NixOSUnreal as base path of your Unreal Engine tree.

This setup requires nix-direnv, allowing to auto source `.envrc-user` when entering the path and unloading when leaving it!

/!\ IMPORTANT: As Nix flakes copy to the store and as the flake is at the folders root everything inside, including any of your folders gets included /!\

```bash
Unreal/                <- NixOsUnreal project as base folder structure
├── Engines            <- Multiples Unreal Engine versions
│   ├── 56_src
│   ├── 57_src
│   ├── latest_bin
│   └── latest_src
├── README.md
├── flake.nix
├── lib
├── modules
├── scripts
├── .envrc
├── .envrc-user
└── user-config.nix
```
Fortunatly, security settings do not allow to run untrusted .envrc. After reviewing the file you can allow its execution with:

```bash
direnv allow
```
As the direnv is now allowed it will be automatically loaded when entering the folder and unloads when leaving to a parent folder!

This is also a downside as the env will be enabled inside every single of theses folders and can lead to conflicts with other env

### 2. Chaostree direnv, aka hope for the best with auto-activation across all subdirectories :/

You want the auto-activation without border to navigate between the engine folders as well as your projects folder or any folders without the env unloading?

Move the `.envrc` to the root of your workspace, above all projects and adjust the flake path as well as the source_env_if_exists path.

/!\ IMPORTANT: As Nix flakes copy to the store and as the flake is at the folders root everything inside, including any of your folders gets included /!\

```bash
/dev/
|-- .envrc              <- .envrc at the base folder structure
|-- Unreal/
|   |-- Engine/
|   |-- NixOSUnreal/    <- NixOsUnreal flake remain in the project folder
|   ...
|-- MyGame/
|-- OtherProject/
```

```bash
use flake /absolute/path/to/NixOSUnreal
source_env_if_exists /absolute/path/to/NixOSUnreal/.envrc-user
```

```bash
direnv allow ~/dev
```

Everything under `~/dev/` are in the env, always, could lead to collision with other env.

### 3. Nix develop, same as before but even better now! Persistent subshell and no direnv :)

Rock solid and self-contained dev session, or when direnv is not installed.

```bash
cd /path/to/NixOSUnreal
nix develop .
# .envrc-user is sourced automatically by the shellHook
# cd anywhere -- env stays active until you exit
```

`exit` to leave the session.

### nix run, or one-shot commands from anywhere

For launching apps without entering a shell and works from any directory
as long as `UE_PATH` is set (by any of the three methods above, or
exported manually):

```bash
nix run /path/to/NixOSUnreal                    # Start Unreal Editor
nix run /path/to/NixOSUnreal#run-rider          # Start Rider
nix run /path/to/NixOSUnreal#run-vscode         # Start VsCode
nix run /path/to/NixOSUnreal#check-vulkan       # Vulkan diagnostics
nix run /path/to/NixOSUnreal#kill-unreal        # Unreal Engine process cleanup
```

Everything runs inside the FHS sandbox regardless of which method activated
the environment.

---

## Setup: Source Build

Requires access to [EpicGames/UnrealEngine](https://github.com/EpicGames/UnrealEngine).

```bash
git clone git@github.com:EpicGames/UnrealEngine.git --branch release --single-branch
git clone https://github.com/Adrastie/NixOSUnreal.git flake
cd flake && direnv allow
unreal-fhs
cd ../UnrealEngine && ./Setup.sh && ./GenerateProjectFiles.sh && make -j1
```

Set `UE_PATH` in `.envrc-user` to the absolute path of the engine root.

---

## Rider

Start Unreal from inside Rider rather than running both `run-unreal` and `run-rider`.
This ensures both share the same FHS environment and avoids IPC issues.

For source build indexing the default 2 GB JVM heap causes hangs, it can be increased in:

`~/.config/JetBrains/Rider<version>/rider64.vmoptions`
```
-Xms2048m
-Xmx8192m
```

---

## Perforce

`p4` is available inside `unreal-fhs`. For Rider plugin to work outside the sandbox you must add it to your NixOS config:

```nix
environment.systemPackages = with pkgs; [ p4 ];
```

Epic's Perforce depot does not mark engine scripts and binaries with the `+x`
So `p4 sync` strips execute permissions on engine source files...
To fix it, after a new sync run:

```bash
ue-source-fix-perms
```

---

## Known Issues, as usual do not expect epic to fix them anytime soon as they are not affecting windows...

### **UBA packaging errors on random files**
HACK: disable the Unified Build Accelerator:

`~/.config/Epic/UnrealBuildTool/BuildConfiguration.xml`
```xml
<?xml version="1.0" encoding="utf-8" ?>
<Configuration xmlns="https://www.unrealengine.com/BuildConfiguration">
    <BuildConfiguration>
        <bAllowUBAExecutor>false</bAllowUBAExecutor>
        <bAllowUBALocalExecutor>false</bAllowUBALocalExecutor>
    </BuildConfiguration>
</Configuration>
```
Source: https://forums.unrealengine.com/t/ue5-6-compilation-issues-when-using-uba/2644456
Source: https://forums.unrealengine.com/t/unreal-build-accelerator-fails-to-generate-ispc-headers-on-linux/2535786




### epic page on unreal engine 5.7 & sdl3:
https://dev.epicgames.com/documentation/unreal-engine/updating-unreal-engine-on-linux-to-sdl3

### **NVIDIA driver 580.119.02 and all 590.x series**

These driver versions have a confirmed bugs with Unreal Engine on Linux. 

- Affected: 580.119.02, 590.x (including 595.x).
- Working: 580.95, 570.x.

You can check installed driver version with `check-vulkan`.

### **EpicWebHelper GPU crash loop (UE 5.7 regression)**

On UE 5.7, EpicWebHelper spawns a subprocess that fails to initialize Vulkan inside the dev environment as it enters an infinite crash-restart loop consuming 30-40% idle CPU alone even when the editor is minimised...

This regression does not exist in UE 5.5 or 5.6.

Fix: `-ini:Engine:[ConsoleVariables]:r.CEFGPUAcceleration=0` is already included in the default `UE_FIXED_ARGS` in `.envrc-user`. This disables GPU acceleration and stopping the crash loop.

Per-project alternative (Might disable features, need investigation):
```ini
# Config/DefaultEngine.ini
[/Script/WebBrowser.WebBrowserSettings]
bEnableWebBrowser=False
```

### **FPS locked at 60 in the editor**

Known Linux + Vulkan issue, workaround: resize the editor window once. As usual there is no fix from Epic...

### **UE 5.7 source builds: VK\_ERROR\_DEVICE\_LOST crashes**

UE 5.7 source builds have an unfixed race condition causing hard `VK_ERROR_DEVICE_LOST` crashes. As expected no fix is currently planned by Epic...

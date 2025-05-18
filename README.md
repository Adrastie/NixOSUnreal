# Adrastie NixOS Unreal Dev Env


# You are responsible for the proper use of this flake. 
## I decline all responsibility for any damages that may result from the use of this flake.

### Please take a look on the scripts as some of them do contain unsecure functions and 'rm -rvf'!

---

Moving my Unreal Engine Dev Env to an ugly FHS flake.

Not made to be pretty; tailored to suit my needs.

Targeting my workstation, with an nvidia gpu and JetBrain rider, flake was made public for an upcoming game jams.

---


### Usage:
1. Download [Unreal Engine 5.x.x Pre-compiled Binaries](https://www.unrealengine.com/en-US/linux)
2. Extract the archive to a new folder and open it
3. git clone https://github.com/Adrastie/NixOSUnreal.git flake
4. Enter flake folder
5. Run 'nix develop'
6. (Optional) Check Vulkan with `check-vulkan`.
7. - Launch Rider with `run-rider` and launch Unreal Engine from Rider.
7. - OR
7.  Launch Unreal Engine with 'run-unreal'
8. If you are having engine issues or an undying process, run `kill-unreal` in the FHS to check and/or kill the Unreal process.



Warning: If you are using Wayland with the Unreal Engine, the Popup keyboard input may not work at all. To find more information and an unsecured but unavoidable workaround, run “kde-wayland-settings”.

#### Example structure:
```
UnrealEngine5.5.4bin
├── Engine
├── FeaturePacks
├── flake <---| Put flake here
├── Samples
└── Templates
```

Warning: This repo is not the recommended way to use NixFlake.

Based/ported from my Thumbleweed jail, which performs better and make Unreal Engine more responsive than on my Windows installation.

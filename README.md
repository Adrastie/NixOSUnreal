# Adrastie NixOS Unreal Dev Env


---

Moving my Unreal Engine Dev Env to FHS flake/develop env.

Not made to be pretty; tailored to suit my needs.

Targeting my workstation, with an nvidia gpu and JetBrain rider, flake was made public for an upcoming game jams.

---


### Usage:

## Unreal Linux Binary:
1. Download [Unreal Engine 5.x.x Pre-compiled Binaries](https://www.unrealengine.com/en-US/linux)
2. Extract the archive to a new folder and open it
3. In a terminal inside the base Unreal Engine Binaries folder run `git clone https://github.com/Adrastie/NixOSUnreal.git flake`
4. Enter flake folder
5. Run `nix develop`
6. (Optional) Check Vulkan with `check-vulkan`.
 - Launch Rider with `run-rider` and launch Unreal Engine from Rider.
 - OR
 - Launch Unreal Engine with `run-unreal`
7. If you are having engine issues or an undying process, run `kill-unreal` in the FHS to check and/or kill the Unreal process.



## Warning: If you are using Wayland with the Unreal Engine, the Popup keyboard input may not work at all. To find more information and an unsecured but unavoidable workaround, run `kde-wayland-settings`.
=======
3. `git clone https://github.com/Adrastie/NixOSUnreal.git flake`
4. `cd flake && nix develop`
5. (Optional) Check Vulkan with `check-vulkan`.
6. - Launch Rider with `run-rider` and launch Unreal Engine from Rider.
 - OR
 - Launch Unreal Engine with `run-unreal`
6. If you are having engine issues or an undying process, run `kill-unreal` in the FHS to check and/or kill the Unreal process.

#### Example structure:
```
UnrealEngine5.5.4bin
├── Engine
├── FeaturePacks
├── flake <---| Put flake here
├── Samples
└── Templates
```

---

## Build Unreal Engine from sources:
1. You must have access to Unreal Engine github repository
2. `git clone git@github.com:EpicGames/UnrealEngine.git --branch release --single-branch`
3. `git clone https://github.com/Adrastie/NixOSUnreal.git flake`
4. `cd flake && nix develop`
5. `unreal-fhs`
6. `cd ../UnrealEngine`
7. `./Setup.sh`
8. `./GenerateProjectFiles.sh`
9. `make -j1' we must use '-j1`
10. Once compiled you will find the binary in the UnrealEngine folder `Engine/Binaries/Linux/UnrealEditor`

#### Example structure:
```
UnrealEngineSources
├── flake <---| Put flake here
├── UnrealEngine
```


Warning: If you are using Wayland with the Unreal Engine, the Popup keyboard input may not work at all. To find more information and an unsecured but unavoidable workaround, run “kde-wayland-settings”.


Based/ported from my Thumbleweed jail, which performs better and make Unreal Engine more responsive than on my Windows installation.

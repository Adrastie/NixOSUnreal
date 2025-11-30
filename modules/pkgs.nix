{ pkgs }:

let
  # Hardcoded DotnetPkg version :[
  dotnetPkg = with pkgs.dotnetCorePackages; combinePackages [
    sdk_8_0
  ];
in {
  inherit dotnetPkg;
  
  debugTools = with pkgs; [
    gdb
    lldb
    elfutils
    binutils
    strace
    lsof
    pciutils
    procps
    psmisc
  ];

  audioTools = with pkgs; [
    pulseaudio
    alsa-lib
    pipewire
    libpulseaudio
  ];

  gpuTools = with pkgs; [
    mesa
    libglvnd
    libva
    amdvlk
    intel-media-driver
    intel-compute-runtime
    intel-ocl
    linuxPackages.nvidia_x11
  ];

  devTools = with pkgs; [
    python3
    cmake
    git
    perl
    pkg-config
    clang_16
    llvmPackages_16.libcxx
    lld_16
    gnumake
    cairo
    curl
    dbus
    bash
    coreutils
    # Libs required to run compiled version
    libgbm
    expat
    atk
    libdrm
    # UDEV stuff
    udev
    systemd
  ];

  vulkanStuff = with pkgs; [
    vulkan-loader
    vulkan-headers
    vulkan-tools
    vulkan-validation-layers
    shaderc
  ];

  videoTools = with pkgs; [
    SDL2
    SDL2_image
    SDL2_mixer
    SDL2_ttf
  ];

  riderDev = with pkgs; [
    dotnetPkg
    mono
    jetbrains.rider
    zlib
    jdk
  ];

  waylandStuff = with pkgs; [
    glfw-wayland
    libsForQt5.kwayland
    qt6.qtwayland
    wayland
    xwayland
  ];

  xorgStuff = with pkgs.xorg; [
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
    libXft
    libXinerama
    libXpresent
    libXxf86vm
  ];

  basicStuff = with pkgs; [
    eudev
    fontconfig
    freetype
    glib
    icu
    libGL
    libGLU
    libuuid
    nspr
    nss
    openssl
    pango
    xkeyboard_config
    libxkbcommon
    xdg-desktop-portal
    xdg-desktop-portal-gtk
    libsForQt5.xdg-desktop-portal-kde
    qt6.qtbase
    libsForQt5.qt5.qtbase
  ];
}

{ pkgs, cfg ? {} }:

let
  dotnetPkg = pkgs.dotnetCorePackages.sdk_8_0;
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
    libpulseaudio
    alsa-lib
    pipewire
    libjack2
    libogg
    libvorbis
    libsamplerate
    flac
    libtheora
    speex
    libmikmod
  ];

  gpuTools = with pkgs; [
    mesa
    libglvnd
    libva
    libvdpau
  ];

  devTools = with pkgs; [
    python3
    cmake
    perl
    pkg-config
    # Upgraded to clang-20 for UE 5.7, UE 5.6 need clang-18 :(
    clang_20
    clang-tools
    llvmPackages_20.libcxx
    llvmPackages_20.libclang.lib
    lld_20
    gnumake
    cairo
    curl
    dbus
    bash
    coreutils
    libgbm
    expat
    atk
    libdrm
    systemd
    stdenv.cc.cc
    xz
    bzip2
  ]
  ++ (if cfg.enableGit or true then [ pkgs.git ] else [])
  ++ (if cfg.enableP4  or true then [ pkgs.p4  ] else []);

  vulkanStuff = with pkgs; [
    vulkan-loader
    vulkan-headers
    vulkan-tools
    vulkan-validation-layers
    shaderc
  ];

  # SDL2 for UE 5.6
  # SDL3 for UE 5.7
  # NOTE: SDL1 was removed as we do not use UE4 anymore
  videoTools = with pkgs; [
    SDL2
    SDL2_image
    SDL2_mixer
    SDL2_ttf
    sdl3
    freeglut
  ];

  ideTools = with pkgs; [
    dotnetPkg
    zlib
    jdk
  ] ++ (if cfg.enableVscode or true then with pkgs; [ vscode ] else []);

  waylandStuff = with pkgs; [
    glfw
    kdePackages.kwayland
    qt6.qtwayland
    wayland
    xwayland
  ];

  xorgStuff = with pkgs; [
    libice
    libsm
    libx11
    libxcb
    libxcomposite
    libxcursor
    libxdamage
    libxext
    libxfixes
    libxi
    libxrandr
    libxrender
    libxscrnsaver
    libxshmfence
    libxtst
    libxft
    libxinerama
    libxpresent
    libxxf86vm
    libxmu
    libxt
    libpciaccess
    libxcb-util
    libxcb-image
    libxcb-keysyms
    libxcb-render-util
    libxcb-wm
  ];

  basicStuff = with pkgs; [
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
    kdePackages.xdg-desktop-portal-kde
    qt6.qtbase
    libsForQt5.qt5.qtbase
    harfbuzz
    pixman
    fribidi
    libthai
    gdk-pixbuf
    librsvg
    libxml2
    libxcrypt-legacy
    gmp
    p11-kit
  ];

  # Libraries for JetBrains Toolbox
  # Source: https://nixos.wiki/wiki/Jetbrains_Tools
  toolboxLibs = with pkgs; [
    at-spi2-atk
    at-spi2-core
    cups
    dbus-glib
    desktop-file-utils
    e2fsprogs
    fuse
    fuse3
    gst_all_1.gstreamer
    gst_all_1.gst-plugins-base
    gst_all_1.gst-plugins-ugly
    gtk2
    keyutils.lib
    libappindicator-gtk2
    libcaca
    libcanberra
    libcap
    libdbusmenu
    libgcrypt
    libgpg-error
    libidn
    libjpeg
    libpng12
    libtiff
    libudev0-shim
    libusb1
    libvpx
    tbb
  ];
}

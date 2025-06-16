{pkgs, ...}: {
  imports = [
    ../../../modules/home-manager/common.nix
    ../../../modules/home-manager/thunar.nix
    ../../../modules/home-manager/terminal.nix
    ../../../modules/home-manager/wayland-fixes.nix
    ../../../modules/home-manager/gui
    ./autostart.nix
  ];

  home.username = "lloyd";
  home.homeDirectory = "/home/lloyd";
  home.stateVersion = "24.11";


  home.packages = with pkgs; [
    # Utils
    kdePackages.xwaylandvideobridge
    unzip
    atool
    httpie
    evtest
    scrcpy
    btop
    openvpn

    # Dev
    vscode
    cargo
    git
    gnumake
    gcc
    pkg-config
    cmake
    jdk21
    gradle
    nodejs_24
    pnpm_9

    # Audio
    easyeffects
    audacity
    spotify

    # Documents
    geeqie
    zathura
    texlive.combined.scheme-full
    xournalpp

    # Comms
    discord

    # Game
    prismlauncher
  ];
}

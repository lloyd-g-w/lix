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
    unzip
    atool
    httpie
    evtest
    scrcpy
    btop
    openvpn

    # Dev
    # oxcaml.oxcaml
    # oxcaml.ocamlformat
    # oxcaml.ocaml-lsp
    opam
    dune_3
    autoconf
    python3
    vscode
    git
    gnumake
    gcc
    pkg-config
    cmake
    jdk21
    gradle
    nodejs_24
    pnpm_9
    rustup

    # Media / Audio
    easyeffects
    audacity
    spotify
    vlc

    # Documents
    geeqie
    zathura
    texlive.combined.scheme-full
    xournalpp
    typst

    # Comms
    discord

    # Game
    prismlauncher
  ];
}

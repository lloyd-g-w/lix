{
  pkgs,
  config,
  ...
}: {
  imports = [
    ../../../modules/home-manager/common.nix
    ../../../modules/home-manager/thunar.nix
    ../../../modules/home-manager/terminal.nix
    ../../../modules/home-manager/wayland-fixes.nix
    ../../../modules/home-manager/gui
    ./autostart.nix
    ../../../scripts/switch.nix
    ../../../scripts/dev.nix
  ];

  lix.compositor = "niri";

  home.username = "lloyd";
  home.homeDirectory = "/home/lloyd";
  home.stateVersion = "24.11";

  home.sessionVariables = {
    NH_FLAKE = config.lix.dir;
  };

  home.packages = with pkgs; [
    # Utils
    nh # Nix helper
    kdePackages.filelight # disk usage gui
    unzip
    atool
    httpie
    evtest
    scrcpy
    btop
    openvpn
    codex
    nautilus # Might want to get rid of thunar and just have nautilus?
    bottles
    piper

    # Dev
    # oxcaml.oxcaml
    # oxcaml.ocamlformat
    # oxcaml.ocaml-lsp
    docker
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
    bun

    zig

    # Rust
    cargo
    rustc

    # Media / Audio
    easyeffects
    audacity
    spotify
    vlc

    # Documents
    geeqie
    zathura
    xournalpp
    typst

    # Latex
    texlive.combined.scheme-full
    # Minted code block deps
    python3Packages.latexrestricted
    python3Packages.latex2pydata
    python3Packages.pygments

    # Comms
    discord

    # Game
    prismlauncher

    # Misc
    neofetch
    cmatrix
  ];
}

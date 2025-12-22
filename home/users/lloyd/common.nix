{
  pkgs,
  lix,
  ...
}: {
  imports = [
    ../../modules/registry.nix
    ../../modules/terminal.nix
    ../../modules/wayland-fixes.nix
    ../../modules/gui
  ];

  programs.lim = {
    enable = true;
    devPath = "/home/lloyd/projects/lim";
  };

  home.username = "lloyd";
  home.homeDirectory = "/home/lloyd";
  home.stateVersion = "24.11";

  home.sessionVariables = {
    NH_FLAKE = lix.dir; # for nix helper to not require a path
  };

  home.packages = with pkgs; [
    # Utils
    nh # Nix helper
    pkgs.lix.dev
    kdePackages.filelight # disk usage gui
    unzip
    atool
    httpie
    evtest
    scrcpy
    btop
    openvpn
    codex
    nautilus
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

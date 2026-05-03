{
  pkgs,
  lib,
  lix,
  ...
}: {
  imports = [
    ../../modules/common.nix
    ../../modules/terminal.nix
  ];

  programs.lim = {
    enable = true;
  };

  home.username = "lloyd";
  home.homeDirectory = "/home/lloyd";
  home.stateVersion = "24.11";

  home.sessionVariables = {
    NH_FLAKE = "path:" + lix.dir; # for nix helper to not require a path
  };

  home.packages = with pkgs; [
    # Utils
    ncdu # disk usage tui
    unzip
    atool
    httpie
    evtest
    btop
    openvpn
    nh # Nix helper

    # Dev
    git
    gnumake
    # gcc
    pkg-config
    cmake
    jdk21
    gradle
    nodejs
    pnpm_9
  ];

  programs.tmux = {
    shortcut = lib.mkForce "a";
  };
}

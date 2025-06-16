{pkgs, ...}: {
  imports = [
    ../../../modules/home-manager/common.nix
    ../../../modules/home-manager/terminal.nix
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
    btop
    openvpn

    # Dev
    git
    gnumake
    gcc
    pkg-config
    cmake
    jdk21
    gradle
    nodejs_24
    pnpm_9
  ];
}

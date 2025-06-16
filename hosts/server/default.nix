{...}: {
  imports = [
    ./hardware-configuration.nix
    ../../modules/nixos/common.nix
    ../../modules/nixos/users/lloyd.nix
  ];

  system.stateVersion = "24.11";
  networking.hostName = "server";

  nix.settings.trusted-users = [
    "root"
    "lloyd"
  ];

  programs.zsh.enable = true;
}

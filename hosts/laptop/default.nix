{...}: {
  imports = [
    ./hardware-configuration.nix
    ../../modules/nixos/common.nix
    ../../modules/nixos/nvidia.nix
    ../../modules/nixos/gui.nix
    ../../modules/nixos/logitech-remap.nix
    ../../modules/nixos/users/lloyd.nix
  ];

  system.stateVersion = "24.11";
  networking.hostName = "laptop";

  nix.settings.trusted-users = [
    "root"
    "lloyd"
  ];

  programs.firefox.enable = true;
  programs.zsh.enable = true;

  # Steam
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
    localNetworkGameTransfers.openFirewall = true; # Open ports in the firewall for Steam Local Network Game Transfers
  };
}

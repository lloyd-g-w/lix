{
  imports = [
    ./hardware-configuration.nix
    ../../modules/common.nix
    ../../modules/nvidia.nix
    ../../modules/gui.nix
    ../../modules/logitech-remap.nix
    ../../modules/users/lloyd.nix
  ];

  # nix.registry = {
  #   # Replace 'lix' with the name you want to use
  #   lix = {
  #     from = {
  #       type = "indirect";
  #       id = "lix";
  #     };
  #     to = {
  #       type = "path";
  #       path = "/absolute/path/to/your/flake";
  #     };
  #   };
  # };

  system.stateVersion = "24.11";
  networking.hostName = "desktop";
  hardware.logitech.wireless.enable = true;

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  nix.settings.trusted-users = ["@wheel"]; # Allow all wheel group users extra nix perms

  programs.firefox.enable = true;
  programs.zsh.enable = true;

  networking.firewall.allowedTCPPorts = [1701 5432 57621];
  networking.firewall.allowedUDPPorts = [5353];

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    localNetworkGameTransfers.openFirewall = true;
  };

  virtualisation.docker.enable = true;
}

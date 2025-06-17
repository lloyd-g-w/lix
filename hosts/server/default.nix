{...}: {
  imports = [
    ./hardware-configuration.nix
    ../../modules/nixos/common.nix
    ../../modules/nixos/users/lloyd.nix
  ];

  system.stateVersion = "24.11";
  networking.hostName = "server";

  # Bootloader.
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";
  boot.loader.grub.useOSProber = true;

  nix.settings.trusted-users = [
    "root"
    "lloyd"
  ];

  services.openssh = {
    enable = true;
    ports = [143];
    settings = {
      UseDns = true;
      PasswordAuthentication = false;
    };
  };

  networking.firewall.allowedTCPPorts = [80];
  programs.zsh.enable = true;
}

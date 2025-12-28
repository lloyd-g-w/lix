{
  imports = [
    ./hardware-configuration.nix
    ../../modules/common.nix
    ../../modules/nvidia.nix
    ../../modules/gui.nix
    ../../modules/logitech-remap.nix
    ../../modules/users/lloyd.nix
  ];

  boot.loader.grub = {
    enable = true;
    # Use "nodev" for UEFI systems; for Legacy BIOS, use your drive path (e.g., "/dev/sda")
    device = "nodev";
    efiSupport = true;

    # This is the key line to find Windows
    useOSProber = true;
  };

  # For vm support via virt-manager and libvirtd
  virtualisation.libvirtd.enable = true;
  virtualisation.spiceUSBRedirection.enable = true;
  programs.virt-manager.enable = true;
  # -----

  system.stateVersion = "24.11";
  networking.hostName = "desktop";
  hardware.logitech.wireless.enable = true;

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

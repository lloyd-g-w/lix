{...}: {
  imports = [
    ./hardware-configuration.nix
    ../../modules/common.nix
    ../../modules/nvidia.nix
    ../../modules/gui.nix
    ../../modules/logitech-remap.nix
    ../../modules/users/lloyd.nix
  ];

  system.stateVersion = "24.11";
  networking.hostName = "laptop";

  # Bootloader
  boot.loader.grub = {
    enable = true;
    # Use "nodev" for UEFI systems; for Legacy BIOS, use your drive path (e.g., "/dev/sda")
    device = "nodev";
    efiSupport = true;

    # This is the key line to find Windows
    useOSProber = true;
  };

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

  hardware.nvidia.prime = {
    intelBusId = "PCI:64:0:0";
    nvidiaBusId = "PCI:1:0:0";
  };

  virtualisation.docker.enable = true;
}

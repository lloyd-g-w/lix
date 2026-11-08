{...}: {
  imports = [
    ./hardware-configuration.nix
    ../../modules/common.nix
    ../../modules/nvidia.nix
    ../../modules/gui
    ../../modules/logitech-remap.nix
    ../../modules/users/lloyd.nix
  ];

  system.stateVersion = "24.11";
  networking.hostName = "laptop";

  # Compressed swap in RAM (no swap partition on this machine)
  zramSwap.enable = true;

  # Battery info (UPower) and power profiles for Noctalia's battery widget
  # and control center
  services.upower.enable = true;
  services.power-profiles-daemon.enable = true;

  # Bootloader
  boot.loader.systemd-boot.enable = false;
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "nodev";
  boot.loader.grub.useOSProber = true;
  boot.loader.grub.efiSupport = true;
  # Install GRUB to the fallback path (EFI/BOOT/BOOTX64.EFI) so firmware always
  # finds it, even after a BIOS update wipes the NVRAM boot entries.
  boot.loader.grub.efiInstallAsRemovable = true;
  boot.loader.efi.canTouchEfiVariables = false;
  boot.loader.efi.efiSysMountPoint = "/boot";

  nix.settings.trusted-users = [
    "root"
    "lloyd"
    "@wheel"
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
    # Bus IDs are decimal; lspci shows hex (AMD iGPU is 0000:64:00.0 -> 0x64 = 100)
    amdgpuBusId = "PCI:100:0:0"; # AMD Radeon iGPU (HawkPoint)
    nvidiaBusId = "PCI:1:0:0"; # RTX 3050 Laptop
  };

  virtualisation.docker = {
    enable = true;

    daemon.settings = {
      dns = [
        "1.1.1.1"
        "8.8.8.8"
      ];
    };
  };
}

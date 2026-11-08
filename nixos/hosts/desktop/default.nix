{pkgs, ...}: {
  imports = [
    ./hardware-configuration.nix
    ../../modules/common.nix
    ../../modules/nvidia.nix
    ../../modules/gui
    ../../modules/logitech-remap.nix
    ../../modules/users/lloyd.nix
  ];

  # For nfs
  services.rpcbind.enable = true;
  services.gvfs.enable = true;
  environment.systemPackages = with pkgs; [
    nfs-utils
    gvfs
  ];

  # Extra SSDs (nofail: boot carries on if one is missing or fails to mount)
  # TEAM 2TB, ext4
  fileSystems."/mnt/data" = {
    device = "/dev/disk/by-uuid/aabeb877-3307-42ad-bfca-4f27bfe573e1";
    fsType = "ext4";
    options = ["nofail" "x-systemd.device-timeout=10s"];
  };

  # TEAM 2TB, Windows (NTFS)
  fileSystems."/mnt/windows" = {
    device = "/dev/disk/by-uuid/8694672C94671E45";
    fsType = "ntfs3";
    options = ["nofail" "x-systemd.device-timeout=10s" "uid=1000" "gid=100" "umask=022"];
  };

  # Early KMS: load the NVIDIA driver in the initrd, so it always registers
  # before the Ryzen iGPU (amdgpu). They used to race, which changed the
  # connector names (HDMI-A-1 vs HDMI-A-2, DP-1.. vs DP-4..) from boot to
  # boot. NVIDIA first means its connectors are HDMI-A-1 and DP-1..3.
  boot.initrd.kernelModules = ["nvidia" "nvidia_modeset" "nvidia_uvm" "nvidia_drm"];
  hardware.nvidia.modesetting.enable = true;

  # All monitors are on the RTX 4080; keep Hyprland (aquamarine) off the
  # unused iGPU instead of running multi-GPU. AQ_DRM_DEVICES is a
  # colon-separated list, so it cannot take the by-path name (which has
  # colons): give the card a stable name of its own.
  services.udev.extraRules = ''
    SUBSYSTEM=="drm", KERNEL=="card[0-9]*", ENV{ID_PATH}=="pci-0000:01:00.0", SYMLINK+="dri/nvidia-card"
  '';
  environment.sessionVariables.AQ_DRM_DEVICES = "/dev/dri/nvidia-card";
  # Same for wlroots compositors: the login screen (Noctalia Greeter) and mango.
  environment.sessionVariables.WLR_DRM_DEVICES = "/dev/dri/nvidia-card";

  # Save video memory across suspend and run NVIDIA's suspend/resume hooks.
  # Desktop only: on the laptop (PRIME, RTX 3050) it makes suspend fail
  # instantly with "NVRM: PM suspend notifier failed: 0x62".
  hardware.nvidia.powerManagement.enable = true;

  boot.loader.systemd-boot.enable = false;
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "nodev";
  boot.loader.grub.useOSProber = true;
  boot.loader.grub.efiSupport = true;
  # /boot is only 512M and each initrd is ~110M (NVIDIA driver in the
  # initrd), so keep only the last 3 generations in the boot menu.
  boot.loader.grub.configurationLimit = 3;
  # Install GRUB to the fallback path (EFI/BOOT/BOOTX64.EFI) so firmware always
  # finds it, even after a BIOS update wipes the NVRAM boot entries.
  boot.loader.grub.efiInstallAsRemovable = true;
  boot.loader.efi.canTouchEfiVariables = false;
  boot.loader.efi.efiSysMountPoint = "/boot";

  # For vm support via virt-manager and libvirtd
  virtualisation.libvirtd.enable = true;
  virtualisation.spiceUSBRedirection.enable = true;
  programs.virt-manager.enable = true;
  # -----

  system.stateVersion = "24.11";
  networking.hostName = "desktop";

  # Compressed swap in RAM (no swap partition on this machine)
  zramSwap.enable = true;
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

  virtualisation.docker = {
    enable = true;

    daemon.settings = {
      dns = [
        "1.1.1.1"
        "8.8.8.8"
      ];
    };
  };

  services.openssh = {
    enable = true;
    settings = {
      UseDns = true;
      PasswordAuthentication = true;
    };
  };
}

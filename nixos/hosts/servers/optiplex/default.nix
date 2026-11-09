# optiplex-specific config (imported by ../common.nix)
{...}: {
  # Bootloader.
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";
  boot.loader.grub.useOSProber = true;

  fileSystems = let
    truenas = path: {
      device = "100.87.55.150:${path}";
      fsType = "nfs";
      options = [
        "nfsvers=4"
        "_netdev"
        "nofail"
        "x-systemd.after=netbird.service"
        "x-systemd.requires=netbird.service"
        "x-systemd.mount-timeout=60s"
      ];
    };
  in {
    "/mnt/truenas/configs" = truenas "/mnt/main/configs";
    "/mnt/truenas/media" = truenas "/mnt/main/media";
  };
}

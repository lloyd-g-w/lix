# laptop-specific config (imported by ../common.nix)
{
  config,
  lib,
  ...
}: {
  imports = [../../../modules/nvidia.nix];

  # Bootloader: GRUB in UEFI mode, installed to the EFI partition at /boot,
  # so no disk device (/dev/sda etc.) is needed.
  boot.loader.systemd-boot.enable = false;
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "nodev";
  boot.loader.grub.useOSProber = false;
  boot.loader.grub.efiSupport = true;
  # Install GRUB to the fallback path (EFI/BOOT/BOOTX64.EFI) so firmware always
  # finds it, even after a BIOS update wipes the NVRAM boot entries.
  boot.loader.grub.efiInstallAsRemovable = false;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot";

  # GTX 1060 (Pascal): no open modules, and only the 580 legacy branch
  # supports it (595+ ignores the GPU).
  hardware.nvidia.open = lib.mkForce false;
  hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.legacy_580;

  # GPU in containers via CDI: request it with `devices: [nvidia.com/gpu=all]`.
  hardware.nvidia-container-toolkit.enable = true;

  # TrueNAS storage for the arr stack (lost/apps/arr), over NetBird: TrueNAS
  # only exports these to this host's NetBird IP (100.87.93.5), so the LAN IP
  # won't work. Mounted at boot rather than automounted, because containers
  # bind-mount these paths.
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

  # Mirror TrueNAS's apps user/group (568), which owns the shares and which
  # the containers run as. lloyd joins the group to browse and edit them.
  users.groups.apps.gid = 568;
  users.users.apps = {
    uid = 568;
    group = "apps";
    isSystemUser = true;
  };
  users.users.lloyd.extraGroups = ["apps"];

  # Don't start docker (and its restart:unless-stopped containers) until the
  # shares are mounted, or apps would write fresh configs into the empty
  # local mountpoint directories.
  systemd.services.docker.unitConfig.RequiresMountsFor = [
    "/mnt/truenas/configs"
    "/mnt/truenas/media"
  ];
}

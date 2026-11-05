# laptop-specific config (imported by ../common.nix)
{...}: {
  imports = [../../../modules/prigh-worker.nix];

  # Bootloader: GRUB in UEFI mode, installed to the EFI partition at /boot,
  # so no disk device (/dev/sda etc.) is needed.
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
}

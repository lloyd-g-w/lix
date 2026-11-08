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
}

# optiplex-specific config (imported by ../common.nix)
{...}: {
  # Runs lost's arr-cpu stack, with its data on TrueNAS.
  imports = [../../../modules/truenas-mounts.nix];

  # Bootloader.
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";
  boot.loader.grub.useOSProber = true;
}

# Oracle Cloud Ampere A1 VM (aarch64, UEFI, virtio). Hand-written: disks and
# filesystems are in ./disko.nix, so there are no fileSystems here.
{
  lib,
  modulesPath,
  ...
}: {
  imports = [(modulesPath + "/profiles/qemu-guest.nix")];

  boot.initrd.availableKernelModules = ["xhci_pci" "virtio_pci" "virtio_scsi" "usbhid"];
  boot.initrd.kernelModules = [];
  boot.kernelModules = [];
  boot.extraModulePackages = [];

  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";
}

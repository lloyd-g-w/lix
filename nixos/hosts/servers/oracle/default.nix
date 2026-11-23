# oracle-specific config (imported by ../common.nix)
#
# Oracle Cloud Ampere A1 VM, public at 137.23.14.13: the edge server. Runs
# lost's laefik (Traefik for every public site) and netbird (the NetBird
# server). Installed with nixos-anywhere; see README.md in this folder.
{inputs, ...}: let
  sshKeys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAppeWlM3pu4osKgwEXu0LWIdGOVEqh+TJIwISc2afUk lloyd.williams1062@gmail.com"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKV6zGIza3ApBvryfV4cI+ADsns2HVht820SfqsIMC2t lloyd.williams1062@gmail.com"
  ];
in {
  imports = [
    inputs.disko.nixosModules.disko
    ./disko.nix
    # ../../../modules/truenas-mounts.nix
  ];

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

  # Oracle's web console (Console connection) is the serial port: the way in
  # when SSH is not.
  boot.kernelParams = ["console=tty1" "console=ttyAMA0,115200"];

  # A fresh install has no passwords and no keys: without these, SSH (key-only)
  # would lock everyone out. Root is there to set lloyd's password once
  # (`ssh -p 143 root@... passwd lloyd`, needed for sudo).
  users.users.lloyd.openssh.authorizedKeys.keys = sshKeys;
  users.users.root.openssh.authorizedKeys.keys = sshKeys;

  # traefik runs with host networking, so every port it listens on must be
  # open here (Docker only opens the ports it publishes itself). Keep in step
  # with lost's apps/laefik/traefik.yml. Oracle's security list must allow
  # them too, as well as SSH on 143.
  networking.firewall = {
    allowedTCPPorts = [
      80
      443
      33010 # anytype
      30143 # forgejo ssh
      25580 # creative.mc
      42420 # vintagestory
    ];
    allowedUDPPorts = [
      3478 # netbird STUN
      33020 # anytype
      2456 # valheim
      51822 # vpn (wireguard)
    ];
  };
}

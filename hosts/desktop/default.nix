{pkgs, ...}: {
  imports = [
    ./hardware-configuration.nix
    ../../modules/nixos/common.nix
    ../../modules/nixos/nvidia.nix
    ../../modules/nixos/gui.nix
    ../../modules/nixos/logitech-remap.nix
    ../../modules/nixos/users/lloyd.nix
  ];

  programs.mango.enable = true;
  system.stateVersion = "24.11";
  networking.hostName = "desktop";
  hardware.logitech.wireless.enable = true;

  services.ratbagd = {
    enable = true;
    package = pkgs.libratbag.overrideAttrs (oldAttrs: {
      version = "master-latest";

      src = pkgs.fetchFromGitHub {
        owner = "libratbag";
        repo = "libratbag";
        # fetching "master" ensures we get the Layout 0x05 C-code fix
        rev = "master";
        hash = "sha256-2x23nHcGIU7Zec51qsbMJnWPojCh7TMh15c5cClj5kw=";
      };

      # We KEEP the manual file injection. Even if master has the file,
      # overwriting it here guarantees ratbagd finds the device.
      postInstall =
        (oldAttrs.postInstall or "")
        + ''
          cat > $out/share/libratbag/logitech-g502-x-plus.device <<EOF
          [Device]
          Name=Logitech G502 X Plus
          DeviceMatch=usb:046d:c095
          Driver=hidpp20
          DeviceType=mouse
          EOF
        '';

      nativeBuildInputs =
        (oldAttrs.nativeBuildInputs or [])
        ++ [
          pkgs.python3
          pkgs.libevdev
          pkgs.valgrind
          pkgs.check
        ];
    });
  };

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  services.desktopManager.cosmic.enable = true;

  nix.settings.trusted-users = [
    "root"
    "lloyd"
  ];

  programs.firefox.enable = true;
  programs.zsh.enable = true;
  networking.firewall.allowedTCPPorts = [1701 5432 57621];
  networking.firewall.allowedUDPPorts = [5353];
  # Steam
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
    localNetworkGameTransfers.openFirewall = true; # Open ports in the firewall for Steam Local Network Game Transfers
  };

  virtualisation.docker.enable = true;
}

{
  inputs,
  pkgs,
  ...
}: let
  inherit (inputs) home-manager;
in {
  users.users.lloyd = {
    isNormalUser = true;
    description = "Lloyd Williams";
    extraGroups = [
      "wheel" # Allows use of sudo
      "networkmanager"
      "input"
      "plugdev"
      "audio"
      "video"
      # Not "docker": it is as good as root (it can read every secret), so
      # Docker goes through sudo.
      "libvirtd"
      "kvm"
      "dialout"
      "adbusers"
    ];
    shell = pkgs.zsh;
    packages = [home-manager.packages.${pkgs.stdenv.hostPlatform.system}.home-manager];
  };

  services.netbird.enable = true;
}

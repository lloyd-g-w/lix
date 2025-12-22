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
      "docker"
    ];
    shell = pkgs.zsh;
    packages = [home-manager.packages.${pkgs.stdenv.hostPlatform.system}.home-manager];
  };
}

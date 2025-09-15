{
  pkgs,
  inputs,
  ...
}: {
  users.users.lloyd = {
    isNormalUser = true;
    description = "Lloyd Williams";
    extraGroups = [
      "networkmanager"
      "wheel" # Allows use of 'sudo'
      "input"
      "plugdev"
      "audio" # Often needed for sound
      "video" # Often needed for hardware acceleration
      "docker"
    ];
    shell = pkgs.zsh;
    packages = [inputs.home-manager.packages.${pkgs.system}.home-manager];
  };
}

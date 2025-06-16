{
  pkgs,
  inputs,
  ...
}: {
  users.users.server = {
    isNormalUser = true;
    description = "Server Account";
    extraGroups = [
      "networkmanager"
      "wheel" # Allows use of 'sudo'
      "input"
      "plugdev"
      "audio" # Often needed for sound
      "video" # Often needed for hardware acceleration
    ];
    shell = pkgs.zsh;
    packages = [inputs.home-manager.packages.${pkgs.system}.home-manager];
  };
}

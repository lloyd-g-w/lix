{
  pkgs,
  inputs,
  lib,
  config,
  ...
}: {
  nix.settings = {
    substituters = ["https://hyprland.cachix.org"];
    trusted-public-keys = ["hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="];
  };

  environment.systemPackages = with pkgs; [
    swaylock
    xss-lock
    xwayland
    wl-clipboard
    networkmanagerapplet
    pavucontrol
  ];

  # For file manager
  services.gvfs.enable = true;

  # Enable xserver
  services.xserver = {
    enable = true;

    # Set keyboard layout
    xkb = {
      layout = "au";
      variant = "";
    };
  };

  security.polkit.enable = true;

  # Set display manager
  services.displayManager.gdm = {
    enable = true;
    wayland = true;
    autoSuspend = false;
  };

  # Enable hyprland/sway for display manager
  programs.hyprland.enable = lib.mkIf (config.lix.compositor == "hyprland") true;
  programs.sway.enable = lib.mkIf (config.lix.compositor == "sway") true;

  # Swaylock
  programs.xss-lock.enable = true;
  programs.xss-lock.lockerCommand = "${pkgs.swaylock}/bin/swaylock";
  security.pam.services.swaylock = {};

  # Set environment variables
  environment.sessionVariables = {
    WLR_NO_HARDWARE_CURSORS = "1";
    WLR_NO_LIBSEAT = 1;
    NIXOS_OZONE_WL = "1";
    QT_AUTO_SCREEN_SCALE_FACTOR = "1";
    # Fucking electron on wayland
    ELECTRON_DISABLE_GPU = "1";
  };
}

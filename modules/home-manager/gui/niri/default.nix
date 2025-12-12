{
  config,
  lib,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    niri
    xwayland-satellite
    latus # Custom status bar app
  ];

  xdg.portal.extraPortals = [
    pkgs.xdg-desktop-portal-gtk
    pkgs.xdg-desktop-portal-gnome
  ];

  home.file.".config/niri/config.kdl".source = pkgs.replaceVars ./config.kdl {
    SCREENSHOT = "${../scripts/screenshot.sh}";
    BROWSER = "firefox";
    TERMINAL = "kitty";
    MENU = "walker";
    DEFAULT_AUDIO_SINK = null;
    DEFAULT_AUDIO_SOURCE = null;
  };
}


{
  config,
  lib,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    niri
    xwayland-satellite
  ];

  xdg.portal.extraPortals = [pkgs.xdg-desktop-portal-gtk pkgs.xdg-desktop-portal-gnome];

  # We use substituteAll so things like @SCREENSHOT@ in the config file
  # are replaced with the correct paths, and so config can be done in nix
  home.file.".config/niri/config.kdl".source = pkgs.replaceVars ./config.kdl {
    SCREENSHOT = "${../scripts/screenshot.sh}";
    BROWSER = "firefox";
    TERMINAL = "kitty";
    MENU = "walker";
    DEFAULT_AUDIO_SINK = null;
    DEFAULT_AUDIO_SOURCE = null;
  };
}

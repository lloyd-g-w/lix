{
  pkgs,
  lix,
  lib,
  ...
}: let
  monitors =
    lib.strings.concatMapStringsSep "\n" (m: ''
      output "${m.name}" {
        ${lib.optionalString (m.pos != null)
        "position x=${toString m.pos.x} y=${toString m.pos.y}"}
        scale ${toString m.scale}
      }
    '')
    lix.home.niri.monitors;
in {
  home.packages = with pkgs; [
    niri
    xwayland-satellite
    latus # Custom status bar app
  ];

  home.file.".config/niri/config.kdl".source = pkgs.replaceVars ./config.kdl {
    SCREENSHOT = "${../scripts/screenshot.sh}";
    BACKGROUND = "swaybg -i ${../background.jpg} -m fill";
    BROWSER = "firefox";
    TERMINAL = "kitty";
    MONITORS = monitors;
    MENU = "walker";
    DEFAULT_AUDIO_SINK = null;
    DEFAULT_AUDIO_SOURCE = null;
  };
}

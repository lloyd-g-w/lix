{
  pkgs,
  lix,
  lib,
  ...
}: let
  # niri matches outputs by connector name or by "Make Model Serial".
  outputName = m:
    if m.name != null
    then m.name
    else
      lib.concatStringsSep " "
      (builtins.filter (x: x != null) [m.make m.model m.serial]);

  outputBlock = m: let
    lines =
      lib.optional (m.pos != null)
      "position x=${toString m.pos.x} y=${toString m.pos.y}"
      ++ ["scale ${toString m.scale}"]
      ++ lib.optional (m.mode != null)
      ''mode "${toString m.mode.width}x${toString m.mode.height}${
        lib.optionalString (m.mode.refresh != null) "@${toString m.mode.refresh}"
      }"''
      ++ lib.optional m.vrr "variable-refresh-rate"
      ++ lib.optional (m.niri.extraConfig != "") m.niri.extraConfig;
  in ''
    output "${outputName m}" {
      ${lib.concatStringsSep "\n  " lines}
    }
  '';

  monitors = lib.concatMapStringsSep "\n" outputBlock lix.home.monitors;
in {
  home.packages = with pkgs; [
    niri
    xwayland-satellite
    latus # Custom status bar app
  ];

  home.file.".config/niri/config.kdl".source = pkgs.replaceVars ./config.kdl {
    SCREENSHOT = "${../scripts/screenshot.sh}";
    BACKGROUND = "swaybg -i ${../background.jpg} -m fill";
    BROWSER = "google-chrome";
    TERMINAL = "kitty";
    MONITORS = monitors;
    MENU = "vicinae toggle";
    DEFAULT_AUDIO_SINK = null;
    DEFAULT_AUDIO_SOURCE = null;
  };
}

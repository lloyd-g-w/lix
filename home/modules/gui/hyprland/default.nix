{
  pkgs,
  lix,
  lib,
  inputs,
  ...
}: let
  # A monitor's connector name, or its description "Make Model Serial".
  monitorId = m:
    if m.name != null
    then m.name
    else
      lib.concatStringsSep " "
      (builtins.filter (x: x != null) [m.make m.model m.serial]);

  # Hyprland matches outputs by connector name or by "desc:Make Model Serial".
  outputName = m:
    if m.name != null
    then m.name
    else "desc:" + monitorId m;

  monitorRule = m:
    {
      output = outputName m;
      mode =
        if m.mode != null
        then
          "${toString m.mode.width}x${toString m.mode.height}"
          + lib.optionalString (m.mode.refresh != null) "@${toString m.mode.refresh}"
        else "preferred";
      position =
        if m.pos != null
        then "${toString m.pos.x}x${toString m.pos.y}"
        else "auto";
      scale = toString m.scale;
      vrr =
        if m.vrr
        then 1
        else 0;
    }
    // lib.optionalAttrs m.hdr {
      bitdepth = 10;
      cm = "hdr";
    }
    // m.hyprland.extraSettings;

  monitors =
    lib.concatMapStringsSep "\n"
    (m: "hl.monitor(${lib.generators.toLua {multiline = false;} (monitorRule m)})")
    lix.home.monitors;

  # hyprsplit gives monitors workspace blocks in this order (1-10, 11-20, ...).
  monitorPriority =
    lib.generators.toLua {multiline = false;}
    (map monitorId lix.home.monitors);
in {
  # Loaded with require("hyprsplit") in hyprland.lua
  home.file.".config/hypr/hyprsplit/init.lua".source = "${inputs.hyprsplit}/init.lua";

  home.file.".config/hypr/hyprland.lua".source = pkgs.replaceVars ./hyprland.lua {
    SCREENSHOT = "noctalia msg screenshot-region";
    BROWSER = "google-chrome";
    TERMINAL = "kitty";
    MONITORS = monitors;
    MONITOR_PRIORITY = monitorPriority;
    MENU = "vicinae toggle";
    DEFAULT_AUDIO_SINK = null;
    DEFAULT_AUDIO_SOURCE = null;
  };
}

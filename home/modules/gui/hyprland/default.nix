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

  # Maps HDR textures to the monitor's SDR range (sdr_min/max_luminance) for
  # screencopy, so screenshots (Noctalia's included) and screenshare of the
  # HDR monitor get correct whites. Built against the same Hyprland it runs in.
  hyprland-fix-hdr = pkgs.hyprlandPlugins.mkHyprlandPlugin {
    pluginName = "hyprland-fix-hdr";
    version = inputs.hyprland-fix-hdr.shortRev or "unstable";
    src = inputs.hyprland-fix-hdr;
    installPhase = ''
      runHook preInstall
      install -Dm755 hyprland-fix-hdr.so -t $out/lib
      runHook postInstall
    '';
    meta.description = "HDR alpha blending and SDR capture corrections for Hyprland";
  };

  # hyprsplit gives monitors workspace blocks in this order (1-10, 11-20, ...).
  monitorPriority =
    lib.generators.toLua {multiline = false;}
    (map monitorId lix.home.monitors);
in {
  # Loaded with require("hyprsplit") in hyprland.lua
  home.file.".config/hypr/hyprsplit/init.lua".source = "${inputs.hyprsplit}/init.lua";
  # Loaded with require("compact_workspaces") in hyprland.lua
  home.file.".config/hypr/compact_workspaces/init.lua".source = ./compact_workspaces.lua;

  home.file.".config/hypr/hyprland.lua".source = pkgs.replaceVars ./hyprland.lua {
    SCREENSHOT = "noctalia msg screenshot-region";
    BROWSER = "google-chrome";
    TERMINAL = "kitty";
    MONITORS = monitors;
    MONITOR_PRIORITY = monitorPriority;
    HDR_PLUGIN = "${hyprland-fix-hdr}/lib/hyprland-fix-hdr.so";
    MENU = "vicinae toggle";
    DEFAULT_AUDIO_SINK = null;
    DEFAULT_AUDIO_SOURCE = null;
  };
}

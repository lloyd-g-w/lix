{
  "$mod" = "SUPER";
  "$terminal" = "kitty";
  "$menu" = "anyrun";
  # "$menu" = "wofi --show drun";
  "$fileManager" = "thunar";
  "$browser" = "firefox";

  bindm = [ "$mod, mouse:272, movewindow" "$mod, mouse:273, resizewindow" ];

  exec-once = [
    "hyprpaper"
    "waybar"
    "playerctld daemon"
    "hyprsunset -t 5000"
    "ulauncher --no-window-shadow"
  ];

  monitor = let
    monitorsFile = ./monitors.nix;
    isMonitorsFile = builtins.pathExists monitorsFile;
    monitors = if isMonitorsFile then import monitorsFile else [ ];
  in monitors;

  animation = [ "global, 0" ];

  misc = { disable_hyprland_logo = true; };

  plugin.split-monitor-workspaces = {
    count = 6;
    keep_focused = true;
  };

  input = {
    # Global sensitivity (-1.0 to 1.0)
    # sensitivity = -0.2;
    touchpad = {
      natural_scroll = true;
      clickfinger_behavior = true;
      drag_lock = false;
      tap-and-drag = false;
    };
  };

  general = {
    gaps_in = 5;
    gaps_out = 10;
  };

  bind = let screenshotScript = ./scripts/screenshot.sh;
  in [
    "$mod, RETURN, exec, $terminal"
    "$mod, Q, killactive,"
    "$mod, F, fullscreen,"
    "$mod, M, exit,"
    "$mod, E, exec, $browser"
    "$mod, V, togglefloating,"
    "$mod, D, exec, $menu"

    # Screenshot
    "$mod SHIFT, S, exec, ${screenshotScript}"

    "$mod,H,movefocus,l"
    "$mod,J,movefocus,d"
    "$mod,K,movefocus,u"
    "$mod,L,movefocus,r"

    "$mod SHIFT,H,swapwindow,l"
    "$mod SHIFT,J,swapwindow,d"
    "$mod SHIFT,K,swapwindow,u"
    "$mod SHIFT,L,swapwindow,r"
  ] ++ (
    # workspaces
    # binds $mod + [shift +] {1..9} to [move to] workspace {1..9}
    builtins.concatLists (builtins.genList (i:
      let ws = i + 1;
      in [
        "$mod, code:1${toString i}, split-workspace, ${toString ws}"
        "$mod SHIFT, code:1${toString i}, split-movetoworkspace, ${toString ws}"
      ]) 6));
  bindel = [
    ",XF86AudioRaiseVolume, exec, wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"
    ",XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
    ",XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
    ",XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
    ",XF86MonBrightnessUp, exec, brightnessctl -e4 -n2 set 5%+"
    ",XF86MonBrightnessDown, exec, brightnessctl -e4 -n2 set 5%-"
  ];

  bindl = [
    ",switch:off:Lid Switch, exec, hyprlock --immediate"
    ", XF86AudioNext, exec, playerctl next"
    ", XF86AudioPause, exec, playerctl play-pause"
    ", XF86AudioPlay, exec, playerctl play-pause"
    ", XF86AudioPrev, exec, playerctl previous"
  ];
}

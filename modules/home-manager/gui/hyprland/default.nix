{config, ...}: {
  "$mod" = "SUPER";
  "$terminal" = "kitty";
  # "$menu" = "anyrun";
  "$menu" = "walker";
  "$fileManager" = "thunar";
  "$browser" = "firefox";

  bindm = ["$mod, mouse:272, movewindow" "$mod, mouse:273, resizewindow"];

  exec-once = [
    "hyprpaper"
    "waybar"
    "playerctld daemon"
    # "hyprsunset -t 5000"
    # "ulauncher --no-window-shadow"

    # This is for discord to recognize portals when launched with walker
    "dbus-update-activation-environment --systemd --all"
  ];

  monitor = config.lix.hyprland.monitors;

  animation = ["global, 0"];

  misc = {disable_hyprland_logo = true;};

  plugin.split-monitor-workspaces = {
    count = 6;
    keep_focused = true;
    enable_persistent_workspaces = true;
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
    gaps_in = 0;
    gaps_out = 0;
    layout = "hy3";
  };

  bind = let
    screenshotScript = ./scripts/screenshot.sh;
  in
    [
      "$mod, RETURN, exec, $terminal"
      "$mod, Q, killactive,"
      "$mod, F, fullscreen,"
      "$mod, M, exit,"
      "$mod, E, exec, $browser"
      "$mod, V, togglefloating,"
      "$mod, D, exec, $menu"

      # Screenshot
      "$mod SHIFT, S, exec, ${screenshotScript}"

      "$mod,H,hy3:movefocus,l"
      "$mod,J,hy3:movefocus,d"
      "$mod,K,hy3:movefocus,u"
      "$mod,L,hy3:movefocus,r"

      "$mod SHIFT,H,hy3:movewindow,l"
      "$mod SHIFT,J,hy3:movewindow,d"
      "$mod SHIFT,K,hy3:movewindow,u"
      "$mod SHIFT,L,hy3:movewindow,r"
    ]
    ++ (
      # workspaces
      # binds $mod + [shift +] {1..6} to [move to] workspace {1..6}
      builtins.concatLists (builtins.genList (i: let
          ws = i + 1;
        in [
          "$mod, ${toString ws}, split-workspace, ${toString ws}"
          "$mod SHIFT, ${toString ws}, split-movetoworkspace, ${toString ws}"
        ])
        6)
    );
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

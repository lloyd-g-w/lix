{
  config,
  lib,
  ...
}: {
  modifier = "Mod4"; # "$mod" = "SUPER"
  terminal = "kitty";
  menu = "walker";

  gaps = {
    inner = 0;
    outer = 0;
  };

  input = {
    "*" = {
      tap = "enabled";
      natural_scroll = "enabled";
      dwt = "disabled";
    };
    "type:touchpad" = {
      tap = "enabled";
      natural_scroll = "enabled";
    };
  };

  keybindings = let
    screenshotScript = ../scripts/screenshot.sh;
    mod = "Mod4";
    workspaceBinds = builtins.concatLists (builtins.genList (i: let
        ws = toString (i + 1);
      in [
        "${mod}+${ws} exec swaymsg workspace ${ws}"
        "${mod}+Shift+${ws} move container to workspace ${ws}"
      ])
      6);
  in
    lib.mkOptionDefault ([
        "${mod}+Return exec kitty"
        "${mod}+q kill"
        "${mod}+f fullscreen toggle"
        "${mod}+Shift+e exit"
        "${mod}+e exec firefox"
        "${mod}+v floating toggle"
        "${mod}+d exec walker"
        "${mod}+Shift+s exec ${screenshotScript}"

        "${mod}+h focus left"
        "${mod}+j focus down"
        "${mod}+k focus up"
        "${mod}+l focus right"

        "${mod}+Shift+h move left"
        "${mod}+Shift+j move down"
        "${mod}+Shift+k move up"
        "${mod}+Shift+l move right"
      ]
      ++ workspaceBinds);

  bindsym = {}; # legacy override support if needed

  startup = [
    {command = "hyprpaper";}
    {command = "waybar";}
    {command = "playerctld daemon";}
    {command = "dbus-update-activation-environment --systemd --all";}
  ];

  extraConfig = ''
    bindsym XF86AudioRaiseVolume exec wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+
    bindsym XF86AudioLowerVolume exec wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-
    bindsym XF86AudioMute exec wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
    bindsym XF86AudioMicMute exec wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle
    bindsym XF86MonBrightnessUp exec brightnessctl -e4 -n2 set 5%+
    bindsym XF86MonBrightnessDown exec brightnessctl -e4 -n2 set 5%-
    bindsym XF86AudioNext exec playerctl next
    bindsym XF86AudioPause exec playerctl play-pause
    bindsym XF86AudioPlay exec playerctl play-pause
    bindsym XF86AudioPrev exec playerctl previous
    bindswitch --reload switch:off:Lid Switch exec hyprlock --immediate
  '';
}

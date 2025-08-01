{
  config,
  lib,
  ...
}: let
  mod = "Mod4";
  terminal = "kitty";
  menu = "walker";
  screenshotScript = ../scripts/screenshot.sh;

  # generate workspace binds 1-10 (1-9 use their number, 10 uses 0)
  workspaceBindsFirst9 = lib.concatStringsSep "\n" (lib.concatLists (lib.genList (i: let
      ws = toString (i + 1);
    in [
      "bindsym ${mod}+${ws} exec swaymsg workspace ${ws}"
      "bindsym ${mod}+Shift+${ws} move container to workspace ${ws}"
    ])
    9));

  workspaceBinds10 = ''
    bindsym ${mod}+0 exec swaymsg workspace 10
    bindsym ${mod}+Shift+0 move container to workspace 10
  '';

  workspaceBinds = lib.concatStringsSep "\n" [workspaceBindsFirst9 workspaceBinds10];
in ''
  # ────────────── basic settings ──────────────
  set $mod ${mod}
  set $term ${terminal}
  set $menu ${menu}

  workspace 1

  # ────────────── input ──────────────
  input * {
      tap enabled
      natural_scroll enabled
      dwt disabled
  }
  input type:touchpad {
      tap enabled
      natural_scroll enabled
      drag enabled
      drag_lock disabled
      tap_button_map lmr
      click_method clickfinger
  }

  # ────────────── keybindings ──────────────
  bindsym ${mod}+Return exec ${terminal}
  bindsym ${mod}+q kill
  bindsym ${mod}+f fullscreen toggle
  bindsym ${mod}+Shift+e exit
  bindsym ${mod}+e exec firefox
  bindsym ${mod}+v floating toggle
  bindsym ${mod}+d exec ${menu}
  bindsym ${mod}+Shift+s exec ${screenshotScript}

  bindsym ${mod}+h focus left
  bindsym ${mod}+j focus down
  bindsym ${mod}+k focus up
  bindsym ${mod}+l focus right

  bindsym ${mod}+Shift+h move left
  bindsym ${mod}+Shift+j move down
  bindsym ${mod}+Shift+k move up
  bindsym ${mod}+Shift+l move right

  # workspace bindings
  ${workspaceBinds}

  # ────────────── media & misc binds ──────────────
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
  bindswitch --reload lid:off exec hyprlock --immediate

  # ────────────── mouse bindings for floating windows ──────────────
  # hold $mod and left-click drag to move floating windows
  bindsym --whole-window ${mod}+button1 move
  # hold $mod and right-click drag to resize floating windows
  bindsym --whole-window ${mod}+button3 resize

  # ────────────── startup applications ──────────────
  exec hyprpaper
  exec waybar
  exec playerctld daemon
  exec dbus-update-activation-environment --systemd --all
''

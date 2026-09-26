{
  pkgs,
  lib,
  lix,
  ...
}: let
  # Translate lix.home.monitors into mango `monitorrule` entries.
  # Mango matches name as a regex, so anchor it for an exact match.
  monitorRule = m: let
    opt = k: v: lib.optional (v != null) "${k}:${toString v}";
    params =
      opt "name" (
        if m.name != null
        then "^${m.name}$"
        else null
      )
      ++ opt "make" m.make
      ++ opt "model" m.model
      ++ opt "serial" m.serial
      ++ lib.optionals (m.pos != null) ["x:${toString m.pos.x}" "y:${toString m.pos.y}"]
      ++ ["scale:${toString m.scale}"]
      ++ lib.optionals (m.mode != null) (
        ["width:${toString m.mode.width}" "height:${toString m.mode.height}"]
        ++ opt "refresh" m.mode.refresh
      )
      ++ lib.optional m.vrr "vrr:1"
      ++ lib.optional (m.mango.extraRule != "") m.mango.extraRule;
  in
    lib.concatStringsSep "," params;
in {
  home.packages = [pkgs.latus];

  wayland.windowManager.mango = {
    enable = true;
    systemd.xdgAutostart = true;

    settings = {
      monitorrule = map monitorRule lix.home.monitors;

      # Use a traditional master-stack tiling layout on every tag.
      tagrule = ["id:*,layout_name:tile"];
      default_mfact = 0.5;
      default_nmaster = 1;

      gappih = 0;
      gappiv = 0;
      gappoh = 0;
      gappov = 0;
      borderpx = 2;
      border_radius = 0;
      focuscolor = "0x618c4dff";
      bordercolor = "0x5a5b5eff";
      urgentcolor = "0xde5d68ff";

      xkb_rules_layout = "au";
      numlockon = 1;
      tap_to_click = 1;
      trackpad_natural_scrolling = 1;
      sloppyfocus = 1;
      warpcursor = 0;

      animations = 1;
      animation_duration_move = 150;
      animation_duration_open = 150;
      animation_duration_close = 150;
      animation_duration_tag = 150;

      circle_layout = "tile,scroller";

      bind = [
        "SUPER,Return,spawn,kitty"
        "SUPER,e,spawn,google-chrome"
        "SUPER,d,spawn,vicinae toggle"
        "SUPER+ALT,l,spawn,swaylock"
        "SUPER,q,killclient"
        "SUPER,o,toggleoverview"

        "SUPER,h,focusdir,left"
        "SUPER,j,focusdir,down"
        "SUPER,k,focusdir,up"
        "SUPER,l,focusdir,right"
        "SUPER,Left,focusdir,left"
        "SUPER,Down,focusdir,down"
        "SUPER,Up,focusdir,up"
        "SUPER,Right,focusdir,right"

        "SUPER+SHIFT,h,exchange_client,left"
        "SUPER+SHIFT,j,exchange_client,down"
        "SUPER+SHIFT,k,exchange_client,up"
        "SUPER+SHIFT,l,exchange_client,right"
        "SUPER+SHIFT,Left,exchange_client,left"
        "SUPER+SHIFT,Down,exchange_client,down"
        "SUPER+SHIFT,Up,exchange_client,up"
        "SUPER+SHIFT,Right,exchange_client,right"

        "SUPER+CTRL,h,focusmon,left"
        "SUPER+CTRL,j,focusmon,down"
        "SUPER+CTRL,k,focusmon,up"
        "SUPER+CTRL,l,focusmon,right"
        "SUPER+CTRL+SHIFT,h,tagmon,left"
        "SUPER+CTRL+SHIFT,j,tagmon,down"
        "SUPER+CTRL+SHIFT,k,tagmon,up"
        "SUPER+CTRL+SHIFT,l,tagmon,right"

        "SUPER,u,viewtoleft_have_client,0"
        "SUPER,i,viewtoright_have_client,0"
        "SUPER+CTRL,u,tagtoleft,0"
        "SUPER+CTRL,i,tagtoright,0"

        "SUPER,1,view,1,0"
        "SUPER,2,view,2,0"
        "SUPER,3,view,3,0"
        "SUPER,4,view,4,0"
        "SUPER,5,view,5,0"
        "SUPER,6,view,6,0"
        "SUPER,7,view,7,0"
        "SUPER,8,view,8,0"
        "SUPER,9,view,9,0"
        "SUPER+CTRL,1,tag,1,0"
        "SUPER+CTRL,2,tag,2,0"
        "SUPER+CTRL,3,tag,3,0"
        "SUPER+CTRL,4,tag,4,0"
        "SUPER+CTRL,5,tag,5,0"
        "SUPER+CTRL,6,tag,6,0"
        "SUPER+CTRL,7,tag,7,0"
        "SUPER+CTRL,8,tag,8,0"
        "SUPER+CTRL,9,tag,9,0"

        "SUPER,r,reload_config"
        "SUPER,f,togglemaximizescreen"
        "SUPER+SHIFT,f,togglefullscreen"
        "SUPER,v,togglefloating"
        "SUPER+SHIFT,s,spawn,${../scripts/screenshot.sh}"
        "SUPER+SHIFT,e,quit"
        "CTRL+ALT,Delete,quit"

        "SUPER+SHIFT,r,switch_layout"

        "NONE,XF86AudioRaiseVolume,spawn,wpctl set-volume @DEFAULT_SINK@ 5%+"
        "NONE,XF86AudioLowerVolume,spawn,wpctl set-volume @DEFAULT_SINK@ 5%-"
        "NONE,XF86AudioMute,spawn,wpctl set-mute @DEFAULT_SINK@ toggle"
        "NONE,XF86AudioMicMute,spawn,wpctl set-mute @DEFAULT_SOURCE@ toggle"
        "NONE,XF86AudioPlay,spawn,playerctl play-pause"
        "NONE,XF86AudioNext,spawn,playerctl next"
        "NONE,XF86AudioPrev,spawn,playerctl previous"
        "NONE,XF86MonBrightnessUp,spawn,brightnessctl set 5%+"
        "NONE,XF86MonBrightnessDown,spawn,brightnessctl set 5%-"
      ];

      mousebind = [
        "SUPER,btn_left,moveresize,curmove"
        "SUPER,btn_right,moveresize,curresize"
      ];
      axisbind = [
        "SUPER,UP,viewtoleft_have_client"
        "SUPER,DOWN,viewtoright_have_client"
      ];
    };

    autostart_sh = ''
      latus &
      swaybg -i ${../background.jpg} -m fill &
      playerctld daemon &
    '';
  };
}

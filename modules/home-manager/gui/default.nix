{
  pkgs,
  inputs,
  ...
}: let
  fonts = [pkgs.nerd-fonts.jetbrains-mono];

  environment = with pkgs; [
    brightnessctl
    playerctl

    swaylock
    wlogout

    waybar
    hyprpaper
  ];

  tools = with pkgs; [
    dconf
    networkmanagerapplet

    # Notif manager
    swaynotificationcenter

    # Screenshots
    grim
    slurp
  ];

  cursorName = "phinger-cursors-light";
  cursorSize = 24;
  cursorPackage = pkgs.phinger-cursors;

  system = pkgs.stdenv.hostPlatform.system;
in {
  home.packages = fonts ++ environment ++ tools;

  # Fonts
  fonts.fontconfig.enable = true;

  # Cursor
  home.pointerCursor = {
    name = cursorName;
    package = cursorPackage;
    size = cursorSize;
    gtk.enable = true;
    x11.enable = true;
  };
  home.sessionVariables = {
    XCURSOR_THEME = cursorName;
    XCURSOR_SIZE = cursorSize;
  };

  # Hyprland
  wayland.windowManager.hyprland = {
    package =
      inputs.hyprland.packages.${system}.hyprland;
    portalPackage =
      inputs.hyprland.packages.${system}.xdg-desktop-portal-hyprland;
    plugins = [
      inputs.split-monitor-workspaces.packages.${system}.split-monitor-workspaces
    ];

    systemd.enableXdgAutostart = true;
    enable = true;
    settings = import ./hyprland;
  };

  # Hyprpaper (wallpaper for hyprland)
  home.file.".config/hypr/hyprpaper.conf".text = ''
    preload = ${./hyprland/background.jpg}
    wallpaper = ,${./hyprland/background.jpg}
  '';

  # Waybar
  home.file.".config/waybar".source = ./hyprland/waybar;
  programs.waybar.enable = true;

  # Poweroff menu for waybar
  home.file.".config/wlogout/layout".text = ''
    {
      "label": "lock",
      "action": "swaylock -l -c 3C3836",
      "text": "Lock",
      "keybind": "l"
    },
    {
      "label": "suspend",
      "action": "systemctl suspend",
      "text": "Suspend",
      "keybind": "s"
    },
    {
      "label": "reboot",
      "action": "systemctl reboot",
      "text": "Reboot",
      "keybind": "r"
    },
    {
      "label" : "hibernate",
      "action" : "systemctl hibernate",
      "text" : "Hibernate",
      "keybind" : "h"
    },
    {
      "label": "shutdown",
      "action": "systemctl poweroff",
      "text": "Shutdown",
      "keybind": "p"
    },
    {
      "label": "logout",
      "action": "hyprctl dispatch exit",
      "text": "Logout",
      "keybind": "e"
    }
  '';

  # Application launcher
  programs.walker = {
    enable = true;
    runAsService = true;

    config = {
      search.placeholder = "Search";
      ui.fullscreen = true;
      list = {
        height = 200;
      };
      websearch.prefix = "?";
      switcher.prefix = "/";
    };
  };

  # GTK - dark mode
  gtk = {
    enable = true;
    gtk3.extraConfig = {"gtk-application-prefer-dark-theme" = true;};
    gtk4.extraConfig = {"gtk-application-prefer-dark-theme" = true;};

    theme = {
      package = pkgs.adw-gtk3;
      name = "adw-gtk3-dark";
    };

    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };

    cursorTheme = {
      name = cursorName;
      package = cursorPackage;
      size = cursorSize;
    };
  };

  home.sessionVariables = {QT_QPA_PLATFORMTHEME = "qt6ct";};

  dconf.settings = {
    "org/gnome/desktop/interface" = {color-scheme = "prefer-dark";};
  };
}

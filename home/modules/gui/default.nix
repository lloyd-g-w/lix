{
  config,
  pkgs,
  inputs,
  lib,
  lix,
  ...
}: let
  fonts = [pkgs.nerd-fonts.jetbrains-mono];

  environment = with pkgs; [
    brightnessctl
    playerctl

    swaylock
    wlogout

    swaybg
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

  compositors = ["niri"];

  make_if_compositor = compositor:
    lib.mkIf (lix.compositor == compositor)
    (import ./${compositor} {inherit config lib pkgs system inputs lix;});

  import_list = builtins.map make_if_compositor compositors;
in {
  imports = import_list;

  config = {
    home.packages = fonts ++ environment ++ tools;

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
    xdg.portal = {
      enable = true;

      extraPortals = with pkgs; [
        xdg-desktop-portal-wlr
        xdg-desktop-portal-gtk
        xdg-desktop-portal-gnome
      ];

      config = {
        common.default = ["gnome" "gtk" "wlr"];
      };
    };

    services.gnome-keyring.enable = true;
    xdg.autostart.enable = true;

    home.sessionVariables = {
      NIXOS_OZONE_WL = "1";
      OZONE_PLATFORM = "wayland";
      QT_QPA_PLATFORMTHEME = "qt6ct";
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

    dconf.settings = {
      "org/gnome/desktop/interface" = {color-scheme = "prefer-dark";};
    };
  };
}

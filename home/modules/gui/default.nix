{
  config,
  pkgs,
  inputs,
  lib,
  lix,
  ...
}: let
  fonts = [pkgs.nerd-fonts.jetbrains-mono pkgs.font-awesome];

  environment = with pkgs; [
    brightnessctl
    playerctl
  ];

  tools = with pkgs; [
    dconf
    networkmanager-openvpn
    openvpn

    # Notifications, screenshots, session menu, network/bluetooth panels and
    # night light are all Noctalia's (see ./noctalia)
  ];

  cursorName = "phinger-cursors-light";
  cursorSize = 24;
  cursorPackage = pkgs.phinger-cursors;

  system = pkgs.stdenv.hostPlatform.system;

  compositors = ["niri" "mango" "hyprland"];

  make_if_compositor = compositor:
    lib.mkIf (builtins.elem compositor lix.compositors)
    (import ./${compositor} {inherit config lib pkgs system inputs lix;});

  import_list = map make_if_compositor compositors;
in {
  imports = import_list ++ [./autostart ./noctalia];

  config = {
    home.packages = fonts ++ environment ++ tools;

    # Fonts
    fonts.fontconfig.enable = true;

    # Cursor
    home.pointerCursor = {
      enable = true;
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
      gtk4.theme = config.gtk.theme;

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

{pkgs, ...}: {
  nix.settings = {
    substituters = ["https://hyprland.cachix.org"];
    trusted-public-keys = ["hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="];
  };

  environment.systemPackages = with pkgs; [
    swaylock
    xss-lock
    xwayland
    wl-clipboard
    networkmanagerapplet
    pavucontrol
  ];

  # For file manager
  services.gvfs.enable = true;

  # Enable xserver
  services.xserver = {
    enable = true;

    # Set keyboard layout
    xkb = {
      layout = "au";
      variant = "";
    };
  };

  # Set display manager
  services.displayManager.gdm = {
    enable = true;
    wayland = true;
    autoSuspend = false;
  };

  # Enable hyprland for display manager
  programs.hyprland = {
    enable = true;
    extraSessionVariables = {
      XDG_SESSION_TYPE = "wayland";
      XDG_CURRENT_DESKTOP = "Hyprland";
      XDG_BACKEND = "xdg-desktop-portal";
    };
  };

  # Swaylock
  programs.xss-lock.enable = true;
  programs.xss-lock.lockerCommand = "${pkgs.swaylock}/bin/swaylock";
  security.pam.services.swaylock = {};

  # Set environment variables
  environment.sessionVariables = {
    WLR_NO_HARDWARE_CURSORS = "1";
    NIXOS_OZONE_WL = "1";
    QT_AUTO_SCREEN_SCALE_FACTOR = "1";
    # For xdg portals - mostly discord screen sharing
    XDG_CURRENT_DESKTOP = "Hyprland";
    XDG_SESSION_TYPE = "wayland";
    XDG_DESKTOP_PORTAL = "xdg-desktop-portal-hyprland";
  };

  # Continuing for xdg portals
  systemd.user.services.importXdgEnv = {
    description = "Import XDG vars into user systemd";
    after = ["graphical-session.target"];
    wantedBy = ["default.target"];
    serviceConfig.ExecStart = ''
      /usr/bin/systemctl import-environment \
        XDG_CURRENT_DESKTOP XDG_SESSION_TYPE XDG_DESKTOP_PORTAL
    '';
  };
}

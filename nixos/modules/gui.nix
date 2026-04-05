{
  pkgs,
  lix,
  ...
}: {
  config = {
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

    security.polkit.enable = true;

    # Set display manager
    services.displayManager.gdm = {
      enable = true;
      wayland = true;
      autoSuspend = false;
    };

    # Enable display manager
    programs.niri.enable = lix.compositor == "niri";

    services.displayManager.defaultSession = lix.compositor;

    # Swaylock
    programs.xss-lock.enable = true;
    programs.xss-lock.lockerCommand = "${pkgs.swaylock}/bin/swaylock";
    security.pam.services.swaylock = {};

    # Set environment variables
    environment.sessionVariables = {
      WLR_NO_HARDWARE_CURSORS = "1";
      NIXOS_OZONE_WL = "1";
      QT_AUTO_SCREEN_SCALE_FACTOR = "1";
      # Fucking electron on wayland
      ELECTRON_DISABLE_GPU = "1";
    };
  };
}

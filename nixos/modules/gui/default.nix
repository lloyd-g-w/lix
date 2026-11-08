{
  config,
  pkgs,
  lix,
  lib,
  ...
}: let
  hasCompositor = c: builtins.elem c lix.compositors;
in {
  # Login screen (greetd + Noctalia Greeter)
  imports = [./greeter];

  config = {
    environment.systemPackages = with pkgs; [
      xwayland
      wl-clipboard
      networkmanagerapplet
      pavucontrol
    ];

    programs.mango = {
      enable = hasCompositor "mango";
      # Install mango.desktop so the greeter can start the selected compositor.
      addLoginEntry = hasCompositor "mango";
    };

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

    # Enable display manager
    programs.niri.enable = hasCompositor "niri";

    # Installs the "hyprland" login session and xdg-desktop-portal-hyprland.
    programs.hyprland.enable = hasCompositor "hyprland";

    # Locking (Super+Alt+L, Super+Escape on Hyprland, and before suspend) is Noctalia's lock screen,
    # which authenticates with the "login" PAM service.

    # Kill everything left in the login session on logout, so the next login
    # starts clean. (tmux etc. started from the session die too.)
    services.logind.settings.Login.KillUserProcesses = true;

    # tiny_power_button makes the power button signal init directly
    # (SIGRTMIN+4 = power off), bypassing logind. Pressing it to wake from
    # suspend then shut the machine down. logind handles the button instead.
    boot.blacklistedKernelModules = ["tiny_power_button"];

    # Set environment variables
    environment.sessionVariables = {
      WLR_NO_HARDWARE_CURSORS = "1";
      NIXOS_OZONE_WL = "1";
      QT_AUTO_SCREEN_SCALE_FACTOR = "1";
      # Fucking electron on wayland
      # ELECTRON_DISABLE_GPU = "1";
    };

    # Portals for streaming etc.
    xdg.portal = {
      enable = true;
      xdgOpenUsePortal = true;

      wlr.enable = true;

      extraPortals = with pkgs; [
        xdg-desktop-portal-gnome
        xdg-desktop-portal-gtk
        xdg-desktop-portal-wlr
      ];

      config = {
        common.default = lib.mkForce ["gnome"];

        niri = {
          default = lib.mkForce ["gnome"];

          # fallback: avoid GNOME/niri PipeWire path for Discord
          # "org.freedesktop.impl.portal.ScreenCast" = lib.mkForce ["wlr"];
          "org.freedesktop.impl.portal.ScreenCast" = lib.mkForce ["gnome"];

          "org.freedesktop.impl.portal.Screenshot" = lib.mkForce ["gnome"];
        };

        # The GNOME portal's screencast/screenshot only work on mutter-like
        # compositors, so use Hyprland's own portal there and GTK for the rest.
        hyprland = lib.mkIf (hasCompositor "hyprland") {
          default = lib.mkForce ["hyprland" "gtk"];
          "org.freedesktop.impl.portal.ScreenCast" = lib.mkForce ["hyprland"];
          "org.freedesktop.impl.portal.Screenshot" = lib.mkForce ["hyprland"];
        };
      };
    }; #
  };
}

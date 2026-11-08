{
  config,
  pkgs,
  lix,
  lib,
  ...
}: let
  hasCompositor = c: builtins.elem c lix.compositors;

  # Login is greetd + tuigreet, a text greeter on VT1. Unlike GDM it runs
  # no compositor of its own, so there is no greeter compositor holding the
  # GPU while the session's compositor takes over the displays.

  # tuigreet remembers each user's last session by the path of its .desktop
  # file. The session files live in the store, so their paths change with
  # every rebuild; a stable /etc path keeps the memory across rebuilds.
  sessionsDir = "/etc/greetd/wayland-sessions";
  sessions = config.services.displayManager.sessionData.desktops;

  # Give users the first compositor as their session only if tuigreet has
  # none remembered for them yet, or theirs no longer exists (e.g. a removed
  # compositor). Otherwise their last pick is left alone.
  defaultSession = builtins.head lix.compositors;
  cacheDir = "/var/cache/tuigreet";
  normalUsers = builtins.attrNames (lib.filterAttrs (_: u: u.isNormalUser) config.users.users);
  ensureUserSessions = ''
    mkdir -p ${cacheDir}
    for user in ${lib.escapeShellArgs normalUsers}; do
      file=${cacheDir}/lastsession-path-$user
      current=$(cat "$file" 2>/dev/null || true)
      if [ -n "$current" ] && [ -e "$current" ]; then
        continue
      fi
      echo "Setting tuigreet session for $user to ${defaultSession} (was '$current')"
      printf '%s' ${sessionsDir}/${defaultSession}.desktop > "$file"
      chown greeter:greeter "$file"
    done
  '';

  tuigreet = lib.concatStringsSep " " [
    (lib.getExe pkgs.tuigreet)
    "--sessions ${sessionsDir}"
    "--remember" # pre-fill the last user
    "--remember-user-session"
    "--time"
    "--asterisks"
  ];
in {
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

    # Set display manager
    services.greetd = {
      enable = true;
      useTextGreeter = true;
      settings.default_session.command = tuigreet;
    };
    environment.etc."greetd/wayland-sessions".source = "${sessions}/share/wayland-sessions";
    systemd.services.greetd.preStart = ensureUserSessions;

    # GDM turned these on itself; keep them now it is gone. greetd's PAM
    # service includes "login", which unlocks the keyring at login.
    services.gnome.gnome-keyring.enable = true;
    services.accounts-daemon.enable = true;

    # Enable display manager
    programs.niri.enable = hasCompositor "niri";

    # Installs the "hyprland" login session and xdg-desktop-portal-hyprland.
    programs.hyprland.enable = hasCompositor "hyprland";

    # No defaultSession (the niri module sets one by default); greetd does
    # not use it, ensureUserSessions picks the default instead.
    services.displayManager.defaultSession = null;

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

{
  config,
  pkgs,
  lix,
  lib,
  ...
}: let
  # Login is greetd + Noctalia Greeter, which runs in its own small wlroots
  # compositor. greetd closes the greeter before it starts the session, so
  # only one compositor drives the GPU at a time (GDM kept gnome-shell
  # running behind the session).

  # The monitor marked primary in lix.home.monitors gets the login screen;
  # without one it shows on every monitor.
  primaries = builtins.filter (m: m.primary) lix.home.monitors;
  primary =
    if primaries == []
    then null
    else builtins.head primaries;

  # The greeter matches a connector name, or "Make Model Serial" (the same
  # identifier niri and Hyprland's desc: use).
  monitorId = m:
    if m.name != null
    then m.name
    else lib.concatStringsSep " " (builtins.filter (x: x != null) [m.make m.model m.serial]);

  # Same mode and scale as in the session, so logging in needs no modeset
  # on that monitor.
  primaryOutput = lib.optionalAttrs (primary != null) ({
      name = monitorId primary;
      scale = primary.scale;
    }
    // lib.optionalAttrs (primary.mode != null) ({
        inherit (primary.mode) width height;
      }
      // lib.optionalAttrs (primary.mode.refresh != null) {
        refresh_rate = primary.mode.refresh;
      }));

  # The lix palette, shared with the Noctalia shell.
  lixPalette = (builtins.fromJSON (builtins.readFile ../../../../home/modules/gui/noctalia/palettes/lix.json)).dark;
  palette = {
    primary = lixPalette.mPrimary;
    on_primary = lixPalette.mOnPrimary;
    secondary = lixPalette.mSecondary;
    on_secondary = lixPalette.mOnSecondary;
    tertiary = lixPalette.mTertiary;
    on_tertiary = lixPalette.mOnTertiary;
    error = lixPalette.mError;
    on_error = lixPalette.mOnError;
    surface = lixPalette.mSurface;
    on_surface = lixPalette.mOnSurface;
    surface_variant = lixPalette.mSurfaceVariant;
    on_surface_variant = lixPalette.mOnSurfaceVariant;
    outline = lixPalette.mOutline;
    shadow = lixPalette.mShadow;
    hover = lixPalette.mHover;
    on_hover = lixPalette.mOnHover;
  };

  settings = lib.recursiveUpdate (builtins.fromTOML (builtins.readFile ./greeter.toml)) {
    appearance = {
      inherit palette;
      wallpaper = {
        path = "${../../../../home/modules/gui/background.jpg}";
        fill_mode = "crop";
      };
    };
    cursor.size = 24;
    output = primaryOutput;
  };

  # The greeter remembers the last session in sync.toml. Until one has been
  # picked, start on the first compositor (otherwise it would be the first
  # session found, in name order).
  sessions = config.services.displayManager.sessionData.desktops;
  defaultSession = builtins.head lix.compositors;
  syncFile = "/var/lib/noctalia-greeter/sync.toml";
  ensureDefaultSession = ''
    if ! grep -qs '^\[session\]' ${syncFile}; then
      name=$(sed -n 's/^Name=//p' ${sessions}/share/wayland-sessions/${defaultSession}.desktop | head -n 1)
      echo "Setting the greeter's session to $name"
      printf '\n[session]\nlast = "%s"\n' "$name" >> ${syncFile}
      chown greeter:greeter ${syncFile}
    fi
  '';
in {
  assertions = [
    {
      assertion = builtins.length primaries <= 1;
      message = "lix.home.monitors: at most one monitor can be primary.";
    }
  ];

  services.displayManager.noctalia-greeter = {
    enable = true;
    inherit settings;
    cursorTheme = {
      package = pkgs.phinger-cursors;
      name = "phinger-cursors-light";
    };
  };
  systemd.services.greetd.preStart = ensureDefaultSession;

  # For the greeter's font_family; the session gets it from home-manager.
  fonts.packages = [pkgs.nerd-fonts.jetbrains-mono];

  # No defaultSession (the niri module sets one by default); the greeter
  # does not use it, ensureDefaultSession picks the default instead.
  services.displayManager.defaultSession = null;

  # GDM turned these on itself; keep them now it is gone. greetd's PAM
  # service includes "login", which unlocks the keyring at login.
  services.gnome.gnome-keyring.enable = true;
  services.accounts-daemon.enable = true;

  # Console look for the boot messages and TTYs: Terminus (the default font
  # is tiny on 4K) and the lix palette.
  console = {
    earlySetup = true;
    font = lib.mkDefault "${pkgs.terminus_font}/share/consolefonts/ter-v32n.psf.gz";
    # Slots 0-15: black red green yellow blue magenta cyan gray, then the
    # bright ones. 0 is the background, 7 the default text.
    colors = [
      "2c2d30" # black: surface
      "de5d68" # red
      "618c4d" # green: lix primary
      "dbb671" # yellow
      "57a5e5" # blue
      "bb70d2" # magenta
      "51a8b3" # cyan
      "a7aab0" # gray: text
      "5a5b5e" # darkgray: outline
      "de5d68" # lightred
      "8fb573" # lightgreen
      "dbb671" # lightyellow
      "57a5e5" # lightblue
      "bb70d2" # lightmagenta
      "51a8b3" # lightcyan
      "ffffff" # white
    ];
  };
}

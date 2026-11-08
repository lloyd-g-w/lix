{
  config,
  pkgs,
  lix,
  lib,
  ...
}: let
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

  tuigreetConfig = pkgs.replaceVars ./tuigreet.toml {
    SESSIONS_DIR = sessionsDir;
    HOSTNAME = config.networking.hostName;
  };
in {
  services.greetd = {
    enable = true;
    useTextGreeter = true;
    settings.default_session.command = "${lib.getExe pkgs.tuigreet} --config ${tuigreetConfig}";
  };
  systemd.services.greetd.preStart = ensureUserSessions;
  environment.etc."greetd/wayland-sessions".source = "${sessions}/share/wayland-sessions";

  # No defaultSession (the niri module sets one by default); greetd does
  # not use it, ensureUserSessions picks the default instead.
  services.displayManager.defaultSession = null;

  # GDM turned these on itself; keep them now it is gone. greetd's PAM
  # service includes "login", which unlocks the keyring at login.
  services.gnome.gnome-keyring.enable = true;
  services.accounts-daemon.enable = true;

  # Console look, for the greeter (and the boot messages and TTYs). The
  # console runs at the monitor's native resolution, so the default font
  # is tiny on 4K: Terminus at 32px, loaded in the initrd.
  console = {
    earlySetup = true;
    font = lib.mkDefault "${pkgs.terminus_font}/share/consolefonts/ter-v32n.psf.gz";
    # The lix palette (home/modules/gui/noctalia/palettes/lix.json) in
    # slots 0-15: black red green yellow blue magenta cyan gray, then the
    # bright ones. 0 is the background, 7 the default text.
    colors = [
      "2c2d30" # black: surface (kitty background)
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
      "ffffff" # white: typed input
    ];
  };
}

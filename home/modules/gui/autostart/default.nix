# Shared session start/stop for every compositor.
#
# Each compositor runs one line at startup:  lix-session start
# That (see lix-session.sh):
#   - does nothing if this login session already has a lix session (e.g. a
#     nested compositor started inside it),
#   - clears failed units and gives systemd the compositor's environment,
#   - (re)starts lix-session.target, which starts graphical-session.target
#     and every service in lix.gui.autostart,
#   - starts lix-session-watch, which waits for the logind session to end
#     (logout or compositor crash) and then stops lix-session.target and
#     graphical-session.target, so nothing keeps running against a dead
#     display and the next login starts clean.
#
# Other modules can add programs:  lix.gui.autostart.<name> = "command";
{
  config,
  lib,
  pkgs,
  ...
}: let
  lix-session = pkgs.writeShellApplication {
    name = "lix-session";
    runtimeInputs = [pkgs.coreutils pkgs.dbus pkgs.systemd];
    text = builtins.readFile ./lix-session.sh;
  };
in {
  options.lix.gui.autostart = lib.mkOption {
    type = lib.types.attrsOf lib.types.str;
    default = {};
    description = "Commands run as systemd user services in the lix session, by service name.";
  };

  config = {
    home.packages = [lix-session];

    systemd.user.targets.lix-session.Unit = {
      Description = "lix graphical session (started by lix-session start)";
      BindsTo = ["graphical-session.target"];
      # xdg-desktop-autostart: apps from ~/.config/autostart etc.
      Wants = ["graphical-session-pre.target" "xdg-desktop-autostart.target"];
      After = ["graphical-session-pre.target"];
      Before = ["xdg-desktop-autostart.target"];
    };

    # Media player tracking for playerctl (has its own home-manager service;
    # it needs no display, so it isn't tied to the session)
    services.playerctld.enable = true;

    systemd.user.services =
      lib.mapAttrs (name: command: {
        Unit = {
          Description = "${name} (lix autostart)";
          PartOf = ["lix-session.target"];
          After = ["lix-session.target"];
        };
        Service = {
          ExecStart = command;
          Restart = "on-failure";
        };
        Install.WantedBy = ["lix-session.target"];
      })
      config.lix.gui.autostart;
  };
}

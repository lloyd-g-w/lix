# Machine-specific lix options. Not tracked by git: build with path:.#...
# Every option is listed (with descriptions) in options/default.nix.
{
  lix = {
    # Compositors to install; each gets a session in the login screen
    # (Noctalia Greeter). It remembers the one you last picked; the first is
    # the default until you pick one.
    # One or more of: "niri" "hyprland" "mango"
    compositors = ["niri"];
    # compositors = ["niri" "hyprland"];

    # Which configuration this machine uses: "desktop", "laptop",
    # "server-laptop" or "server-optiplex".
    host = "desktop";

    user = "lloyd";

    # Where this repo is checked out (used by `nh os switch` etc.).
    dir = "$HOME/projects/lix";

    # Monitors, translated to every enabled compositor. Find make, model and
    # serial with `niri msg outputs` or `hyprctl monitors`; monitors not
    # listed here get the compositor's defaults.
    home.monitors = [
      # Match by make/model/serial: survives changing ports.
      {
        make = "Samsung Electric Company";
        model = "Odyssey G70SH";
        serial = "HNAL700108";

        # Optional; without it the compositor picks the "preferred" mode,
        # which is often 60 Hz. Use the exact refresh from the mode list
        # (e.g. 164.984, not 165).
        mode = {
          width = 3840;
          height = 2160;
          refresh = 164.984;
        };

        scale = 1.5; # default 1.0
        pos = {
          x = 0;
          y = 0;
        };

        vrr = false; # variable refresh rate (default false)

        # Show the login screen only on this monitor (at most one; without
        # one it shows on every monitor).
        primary = true;

        # HDR output (Hyprland only; niri and mango ignore it).
        hdr = true;

        # Per-compositor extras, added to what the options above generate:
        hyprland.extraSettings = {
          sdrbrightness = 2.5; # brightness of normal (SDR) content in HDR
        };
        # niri.extraConfig = ''
        #   transform "90"
        # '';
        # mango.extraRule = "rr:1";
      }

      # Or match by connector name (changes if you swap ports).
      # {
      #   name = "DP-2";
      #   scale = 1.25;
      #   pos = { x = 2560; y = 0; };
      # }

      # Minimal: everything else automatic.
      {
        make = "Samsung Electric Company";
        model = "LC27G5xT";
        serial = "HNAW600500";
      }
    ];

    # Extra modules added to every Home Manager / NixOS configuration on this
    # machine, for one-off tweaks without editing the repo's modules.
    # home.sharedModules = [
    #   ({pkgs, ...}: {
    #     home.packages = [pkgs.btop];
    #     # Start something with every graphical session
    #     # (see home/modules/gui/autostart):
    #     lix.gui.autostart.syncthingtray = "${pkgs.syncthingtray}/bin/syncthingtray";
    #   })
    # ];
    # os.sharedModules = [
    #   {
    #     services.tailscale.enable = true;
    #   }
    # ];
  };
}

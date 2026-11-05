# Vicinae launcher, themed to match kitty (OneDark warmer) and opaque.
{lib, ...}: {
  # Stop vicinae's helper processes (node extension manager) with it; the
  # module's KillMode=process left them running after the service stopped.
  # Apps launched from vicinae get their own app-*.scope, so they're not
  # affected.
  systemd.user.services.vicinae.Service.KillMode = lib.mkForce "mixed";

  programs.vicinae = {
    enable = true;
    systemd = {
      enable = true;
      autoStart = true;
      # Start/stop with the shared session (see ../autostart)
      target = "lix-session.target";
      environment = {
        USE_LAYER_SHELL = 1;
      };
    };

    settings = {
      theme.dark.name = "lix";
      launcher_window = {
        opacity = 1.0; # no translucency
        material = "none"; # no blur behind the window
      };
    };

    # Written to ~/.local/share/vicinae/themes/lix.toml
    themes.lix = {
      meta = {
        version = 1;
        name = "lix";
        description = "OneDark (warmer) to match kitty, with the niri accent green";
        variant = "dark";
        inherits = "vicinae-dark";
      };

      colors = {
        core = {
          background = "#2c2d30"; # kitty background
          foreground = "#a7aab0"; # kitty foreground
          secondary_background = "#35363b";
          border = "#5a5b5e";
          accent = "#618c4d"; # niri focus ring
          accent_foreground = "#101012";
        };
        accents = {
          blue = "#57a5e5";
          green = "#8fb573";
          magenta = "#bb70d2";
          orange = "#c49060";
          purple = "#bb70d2";
          red = "#de5d68";
          yellow = "#dbb671";
          cyan = "#51a8b3";
        };
        text = {
          muted = "#818387";
          placeholder = "#5a5b5e";
          danger = "#de5d68";
          success = "#8fb573";
        };
        list.item.selection = {
          background = "#404247";
          foreground = "#a7aab0";
          secondary_background = "#404247";
          secondary_foreground = "#a7aab0";
        };
      };
    };
  };
}

{lib, ...}: {
  options.lix.compositor = lib.mkOption {
    type = lib.types.enum ["sway" "hyprland" "niri"];
    default = "hyprland";
    description = "The compositor for lix (options: hyprland (default), sway, niri)";
  };

  # Make an option for monitors
  options.lix.hyprland = {
    monitors = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = "A list of monitor configuration strings for Hyprland.";
    };

    hy3.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable or disable hy3 (default: false)";
    };
  };

  # Make options for niri
  options.lix.niri = {
    monitors = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = "A list of monitor configuration strings for niri.";
    };
  };

  options.lix = {
    host = lib.mkOption {
      type = lib.types.str;
      default = "desktop";
      description = "The lix hostname of the system.";
    };

    user = lib.mkOption {
      type = lib.types.str;
      default = "lloyd";
      description = "The lix user of the system.";
    };

    dir = lib.mkOption {
      type = lib.types.str;
      default = "$HOME/projects/lix";
      description = "The directory of the main lix config.";
    };
  };
}

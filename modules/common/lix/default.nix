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
}

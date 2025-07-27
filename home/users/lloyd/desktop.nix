{...}: {
  imports = [./common.nix];

  # Setup hyprland monitors with custom option
  lix.hyprland.monitors = ["DP-1, preferred, 0x0, 1" "HDMI-A-2, preferred, auto, 1"];
}

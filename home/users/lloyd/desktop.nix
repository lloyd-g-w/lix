{...}: {
  imports = [./common.nix];

  # Setup hyprland monitors with custom option
  lix.hyprland.monitors = [
    "desc:Samsung Electric Company LC27G5xT HNAW600500, preferred, 0x0, 1"
    "desc:BNQ BenQ XL2411Z C6F00870SL0, preferred, auto, 1"
  ];
}

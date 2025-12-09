{
  config,
  lib,
  pkgs,
  ...
}: {
  wayland.windowManager.sway = {
    enable = true;
    wrapperFeatures.gtk = true; # Fixes common issues with GTK 3 apps
    extraConfig = import ./settings.nix {inherit config lib;};
  };
}

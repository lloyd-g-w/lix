{
  inputs,
  config,
  lib,
  system,
  ...
}: {
  # Hyprland
  wayland.windowManager.hyprland = {
    # package =
    #   inputs.hyprland.packages.${system}.hyprland;
    # portalPackage =
    #   inputs.hyprland.packages.${system}.xdg-desktop-portal-hyprland;
    plugins =
      [
        inputs.split-monitor-workspaces.packages.${system}.split-monitor-workspaces
      ]
      ++ lib.optionals config.lix.hyprland.hy3.enable [
        inputs.hy3.packages.${system}.hy3
      ];

    systemd.enableXdgAutostart = true;
    enable = true;
    settings = import ./settings.nix {inherit config lib;};
  };
}

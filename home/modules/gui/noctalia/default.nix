{
  config,
  pkgs,
  ...
}: {
  # The bar's launcher button opens vicinae (see config.toml)
  imports = [../vicinae];

  home.packages = [pkgs.noctalia];

  # Bar, wallpaper, notifications etc. for every compositor (see ../autostart)
  lix.gui.autostart.noctalia = "${pkgs.noctalia}/bin/noctalia";

  # Read-only config; GUI changes go to ~/.local/state/noctalia/settings.toml.
  xdg.configFile."noctalia/config.toml".source = pkgs.replaceVars ./config.toml {
    WALLPAPER = "${../background.jpg}";
    SCREENSHOT_DIR = "${config.home.homeDirectory}/Pictures/Screenshots";
  };

  # Palette "lix": OneDark (warmer) kitty theme + niri accent green.
  xdg.configFile."noctalia/palettes/lix.json".source = ./palettes/lix.json;
}

{
  config,
  lib,
  pkgs,
  ...
}: {
  # We use substituteAll so things like @SCREENSHOT@ in the config file
  # are replaced with the correct paths, and so config can be done in nix
  home.file.".config/mango/config.conf".source = pkgs.replaceVars ./config.conf {
    MOD = "SUPER";
    # SCREENSHOT = "${../scripts/screenshot.sh}";
    BROWSER = "firefox";
    TERMINAL = "kitty";
    MENU = "walker";
    # DEFAULT_AUDIO_SINK = null;
    # DEFAULT_AUDIO_SOURCE = null;
  };
}

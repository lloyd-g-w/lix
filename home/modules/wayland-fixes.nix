{
  lib,
  pkgs,
  ...
}: let
  waylandPushToTalkFix = pkgs.stdenv.mkDerivation {
    pname = "wayland-push-to-talk-fix";
    version = "unstable";
    src = pkgs.fetchFromGitHub {
      owner = "Rush";
      repo = "wayland-push-to-talk-fix";
      rev = "490f43054453871fe18e7d7e9041cfbd0f1d9b7d";
      sha256 = "11zbqz9zznzncf84jrvd5hl2iig6i1cpx6pwv02x2dg706ns0535";
    };
    nativeBuildInputs = [pkgs.pkg-config];
    buildInputs = [pkgs.libevdev pkgs.xdotool pkgs.libX11];
    installPhase = ''
      mkdir -p $out/bin
      cp push-to-talk $out/bin/push-to-talk
    '';
  };
  ptt = "${waylandPushToTalkFix}/bin/push-to-talk";
  # Discord push-to-talk workaround: one service per key, started with the
  # session and restarted if it dies (e.g. when Xwayland restarts).
  pttServices = {
    ptt-launch1 = "${ptt} /dev/input/keyd-kbd -k KEY_UNKNOWN -n XF86Launch1";
    ptt-launch2 = "${ptt} /dev/input/keyd-kbd -k KEY_MACRO -n XF86Launch2";
  };
in {
  home.packages = [waylandPushToTalkFix];

  lix.gui.autostart = pttServices;

  # Wait between restarts so a slow Xwayland restart doesn't hit the start limit
  systemd.user.services = lib.mapAttrs (_: _: {
    Unit.StartLimitIntervalSec = 0;
    Service.RestartSec = 2;
  }) pttServices;
}

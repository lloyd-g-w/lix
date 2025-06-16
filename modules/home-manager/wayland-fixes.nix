{
  pkgs,
  inputs,
  system,
  ...
}: let
  waylandPushToTalkFix = pkgs.stdenv.mkDerivation {
    pname = "wayland-push-to-talk-fix";
    version = "unstable";

    src = pkgs.fetchFromGitHub {
      owner = "Rush";
      repo = "wayland-push-to-talk-fix";
      rev = "master";
      sha256 = "11zbqz9zznzncf84jrvd5hl2iig6i1cpx6pwv02x2dg706ns0535";
    };

    nativeBuildInputs = [pkgs.pkg-config pkgs.xorg.libX11];
    buildInputs = [pkgs.libevdev pkgs.xdotool];
    installPhase = ''
      # Create the directory structure under $out
      mkdir -p $out/bin $out/share/applications

      # Copy the built binary
      cp push-to-talk $out/bin/push-to-talk
    '';
  };
in {
  home.packages = [waylandPushToTalkFix];
}

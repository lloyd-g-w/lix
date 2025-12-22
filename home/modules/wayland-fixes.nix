{pkgs, ...}: let
  waylandPushToTalkFix = pkgs.stdenv.mkDerivation {
    pname = "wayland-push-to-talk-fix";
    version = "unstable";

    src = pkgs.fetchFromGitHub {
      owner = "Rush";
      repo = "wayland-push-to-talk-fix";
      rev = "490f43054453871fe18e7d7e9041cfbd0f1d9b7d";
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

  xdg.autostart.enable = true;

  home.file.".config/autostart/discord-push-to-talk.desktop".text = ''
    [Desktop Entry]
    Type=Application
    Terminal=false
    Name=Discord Push-to-Talk
    GenericName=Discord Push-to-Talk
    Comment=A workaround app that allows using push-to-talk keybinding in Discord on Wayland
    Exec=sh -c "push-to-talk /dev/input/keyd-kbd -k KEY_PROG1 -n XF86Launch1 & \
            push-to-talk /dev/input/keyd-kbd -k KEY_PROG2 -n XF86Launch2 &"
  '';
}

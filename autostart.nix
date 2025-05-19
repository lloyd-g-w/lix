{
  config,
  pkgs,
  ...
}: {
  xdg.autostart.enable = true;

  home.file = {
    ".config/autostart/discord-push-to-talk.desktop".text = ''
      [Desktop Entry]
      Type=Application
      Terminal=false
      Name=Discord Push-to-Talk
      GenericName=Discord Push-to-Talk
      Comment=A workaround app that allows using push-to-talk keybinding in Discord on Wayland
      Exec=push-to-talk /dev/input/keyd-kbd -k KEY_F19 -n F19
    '';
  };
}

{...}: {
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

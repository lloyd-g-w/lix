{pkgs, ...}: {
  environment.systemPackages = [pkgs.keyd];

  services.keyd.enable = true;

  # Remap side button with keyd to F19 - G Pro wireless
  # environment.etc."keyd/default.conf".text = ''
  #   [ids]
  #   046d:c547
  #
  #   [main]
  #   mouse1 = f19
  # '';

  # G502 X Plus
  environment.etc."keyd/default.conf".text = ''
    [ids]
    046d:c547:db1d61df

    [main]
    stopcd = f19
  '';

  # Add symlink to /dev/input of keyd virtual keyboard
  services.udev.extraRules = ''
    # match the keyd virtual keyboard by its exact name
    SUBSYSTEM=="input", KERNEL=="event*", ATTRS{name}=="keyd virtual keyboard", SYMLINK+="input/keyd-kbd"

    # Keychron keyboard for VIA
    KERNEL=="hidraw*", ATTRS{idVendor}=="3434", ATTRS{idProduct}=="0101", MODE="0666"

    # XP-Pen 9″ PenTablet
    SUBSYSTEM=="usb", ATTR{idVendor}=="28bd", ATTR{idProduct}=="0918", MODE="0666", GROUP="input"
  '';
}

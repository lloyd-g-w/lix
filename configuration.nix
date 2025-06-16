{
  inputs,
  pkgs,
  ...
}: {
  # Bluetooth
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  services.blueman.enable = true;

  # Printing
  services.printing.enable = true;
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

  networking.firewall.allowedTCPPorts = [1701 5432];


  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Enable audio
  services.pulseaudio.enable = false;
  services.dbus.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
    jack.enable = true;
  };

  # Enable flakes
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Australia/Sydney";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_GB.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_AU.UTF-8";
    LC_IDENTIFICATION = "en_AU.UTF-8";
    LC_MEASUREMENT = "en_AU.UTF-8";
    LC_MONETARY = "en_AU.UTF-8";
    LC_NAME = "en_AU.UTF-8";
    LC_NUMERIC = "en_AU.UTF-8";
    LC_PAPER = "en_AU.UTF-8";
    LC_TELEPHONE = "en_AU.UTF-8";
    LC_TIME = "en_AU.UTF-8";
  };

  nix.settings.trusted-users = [
    "root"
    "lloyd"
  ];

  environment.systemPackages = with pkgs; [
    keyd
  ];

  # Steam
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
    localNetworkGameTransfers.openFirewall = true; # Open ports in the firewall for Steam Local Network Game Transfers
  };

  # Remap side button with keyd to F19
  services.keyd.enable = true;
  environment.etc."keyd/default.conf".text = ''
    [ids]
    046d:4079

    [main]
    mouse1 = f19
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

  # Enable some other useful programs
  programs.zsh.enable = true;
  programs.firefox.enable = true;

  # Setup Nvidia drivers
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [nvidia-vaapi-driver];
  };
  services.xserver.videoDrivers = ["nvidia"];
  hardware.nvidia.open = true;

  # X server
  services.xserver = {
    enable = true;

    # Set keyboard layout
    xkb = {
      layout = "au";
      variant = "";
    };
  };

  system.stateVersion = "24.11";
}

# Help is available in the configuration.nix(5) man page and in the NixOS manual (accessible by running ‘nixos-help’).
{
  inputs,
  config,
  pkgs,
  lib,
  ...
}: {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  nix.settings = {
    substituters = ["https://hyprland.cachix.org"];
    trusted-public-keys = ["hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="];
  };

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

  # For file manager
  services.gvfs.enable = true;

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

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

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.lloyd = {
    isNormalUser = true;
    description = "Lloyd Williams";
    extraGroups = [
      "networkmanager"
      "wheel"
      "input"
      "plugdev"
    ];
    shell = pkgs.zsh;
    packages = with pkgs; [inputs.home-manager.packages.${pkgs.system}.home-manager];
  };

  nix.settings.trusted-users = [
    "root"
    "lloyd"
  ];

  # Steam
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
    localNetworkGameTransfers.openFirewall = true; # Open ports in the firewall for Steam Local Network Game Transfers
  };

  # For sway
  security.polkit.enable = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    swaylock
    xss-lock
    xwayland
    wl-clipboard
    networkmanagerapplet
    vim
    wget
    kitty
    pavucontrol
    keyd
  ];

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

  # Set display manager

  services = {
    displayManager.sddm = {
      enable = true;
      wayland.enable = true;
    };
  };

  # Enable hyprland for display manager
  programs.hyprland = {
    enable = true;
  };

  # Swaylock
  programs.xss-lock.enable = true;
  programs.xss-lock.lockerCommand = "${pkgs.swaylock}/bin/swaylock";
  security.pam.services.swaylock = {};

  # Enable some other useful programs
  programs.zsh.enable = true;
  programs.firefox.enable = true;

  # Set environment variables
  environment.sessionVariables = {
    WLR_NO_HARDWARE_CURSORS = "1";
    NIXOS_OZONE_WL = "1";
    QT_AUTO_SCREEN_SCALE_FACTOR = "1";
  };

  # Setup Nvidia drivers
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [nvidia-vaapi-driver];
  };

  hardware.nvidia.open = true;

  # X server
  services.xserver = {
    enable = true;

    # Set nvidia drivers
    videoDrivers = ["nvidia"];

    # Set keyboard layout
    xkb = {
      layout = "au";
      variant = "";
    };
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?
}

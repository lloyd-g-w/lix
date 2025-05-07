{ pkgs, inputs, system, ... }:
with pkgs;
let
  devTools = [ cargo tmux git ];

  devPackages = [ gnumake gcc pkg-config cmake ];

  gamingPackages = [ discord prismlauncher ];

  mediaPackages = [ spotify ];

  fileManager = [
    xfce.thunar
    xfce.tumbler # core thumbnail daemon
    ffmpegthumbnailer # video thumbnailer
    papirus-icon-theme # example high-quality icon theme
  ];

  systemTools = [
    texlive.combined.scheme-full
    zathura
    geeqie
    unzip
    playerctl
    easyeffects
    atool
    httpie
    evtest
    grim
    slurp
    swaynotificationcenter
  ];

  linuxEnvironment = [
    home-manager
    brightnessctl

    hyprlock
    wofi
    waybar
    hyprpaper
    dconf
    networkmanagerapplet
  ];

  fonts = [ nerd-fonts.jetbrains-mono ];

  cursorName = "phinger-cursors-light";
  cursorSize = 24;
  cursorPackage = phinger-cursors;

  # `nix-prefetch-git https://github.com/Rush/wayland-push-to-talk-fix.git`
  waylandPushToTalkFix = stdenv.mkDerivation {
    pname = "wayland-push-to-talk-fix";
    version = "unstable";

    src = fetchFromGitHub {
      owner = "Rush";
      repo = "wayland-push-to-talk-fix";
      rev = "master";
      sha256 = "11zbqz9zznzncf84jrvd5hl2iig6i1cpx6pwv02x2dg706ns0535";
    };

    nativeBuildInputs = [ pkg-config xorg.libX11 ];
    buildInputs = [ libevdev pkgs.xdotool ];
    installPhase = ''
      # Create the directory structure under $out
      mkdir -p $out/bin $out/share/applications

      # Copy the built binary
      cp push-to-talk $out/bin/push-to-talk
    '';
  };

in {
  home.packages = devTools ++ devPackages ++ gamingPackages ++ mediaPackages
    ++ systemTools ++ linuxEnvironment ++ fonts ++ fileManager
    ++ [ waylandPushToTalkFix ];

  imports = [ ./autostart.nix ];

  fonts.fontconfig.enable = true;
  programs.waybar.enable = true;

  home.file.".config/waybar".source = ./hypr/waybar;

  home.file.".config/hypr/hyprpaper.conf".text = ''
    preload = ${./hypr/background.jpg}
    wallpaper = ,${./hypr/background.jpg}
  '';

  home.pointerCursor = {
    name = cursorName;
    package = cursorPackage;
    size = cursorSize;
    gtk.enable = true;
    x11.enable = true;
  };

  home.sessionVariables = {
    XCURSOR_THEME = cursorName;
    XCURSOR_SIZE = cursorSize;
  };

  gtk = {
    enable = true;
    gtk3.extraConfig = { "gtk-application-prefer-dark-theme" = true; };
    gtk4.extraConfig = { "gtk-application-prefer-dark-theme" = true; };

    cursorTheme = {
      name = cursorName;
      package = cursorPackage;
      size = cursorSize;
    };
  };

  home.sessionVariables = { QT_QPA_PLATFORMTHEME = "qt6ct"; };

  dconf.settings = {
    "org/gnome/desktop/interface" = { color-scheme = "prefer-dark"; };
  };

  #Kitty
  xdg.configFile."kitty/themes/gruvbox-material-dark-soft.conf".source =
    builtins.fetchurl {
      url =
        "https://raw.githubusercontent.com/kovidgoyal/kitty-themes/refs/heads/master/themes/GruvboxMaterialDarkSoft.conf";
      sha256 = "04azpbiv3vkqm0af0nl6ij9i0j2i95ij1rxxr2bb2cr3hh78x8yh";
    };
  programs.kitty = lib.mkForce {
    enable = true;
    font = {
      name = "JetBrainsMono Nerd Font";
      size = 14;
    };
    extraConfig = ''
      include themes/gruvbox-material-dark-soft.conf
    '';
  };

  #Zsh
  programs.starship = {
    enable = true;
    settings = builtins.fromTOML (builtins.readFile (builtins.fetchurl {
      url = "https://starship.rs/presets/toml/nerd-font-symbols.toml";
      sha256 = "sha256:05yvqiycb580mnym7q8lvk1wcvpq7rc4jjqb829z3s82wcb9cmbr";
    }));
  };
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    shellAliases = {
      gacp = "git add .; git add -u; git commit -m '🙃'; git push";
    };

    initContent = ''
      set -o vi
      eval "$(starship init zsh)"
      export TERMINAL=kitty
      export EDITOR=nvim
      export VISUAL=nvim
    '';

    oh-my-zsh = {
      enable = true;

      plugins = [ "git" ];
      theme = "robbyrussell";
    };
  };

  # Hyprland
  wayland.windowManager.hyprland = {
    package =
      inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
    portalPackage =
      inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
    plugins = [
      inputs.split-monitor-workspaces.packages.${system}.split-monitor-workspaces
    ];

    systemd.enableXdgAutostart = true;
    enable = true;
    settings = import ./hypr/hyprland.nix;
  };

  # Sway
  wayland.windowManager.sway = {
    enable = true;
    wrapperFeatures.gtk = true; # Fixes common issues with GTK 3 apps
    config = {
      modifier = "Mod4";
      terminal = "kitty";
    };
  };

  # The state version is required and should stay at the version you
  # originally installed.
  home.stateVersion = "24.11";
}

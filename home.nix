{ pkgs, inputs, system, ... }:
with pkgs;
let
  devTools = [ cargo neovim tmux git ];

  devPackages = [ gnumake gcc pkg-config ];

  gamingPackages = [ discord prismlauncher ];

  mediaPackages = [ spotify ];

  systemTools = [
    ripgrep
    playerctl
    easyeffects
    atool
    httpie
    evtest
    grim
    slurp
    xfce.thunar
  ];

  linuxEnvironment = [
    libsForQt5.qt5ct
    qt6ct
    libsForQt5.qtstyleplugin-kvantum
    kdePackages.breeze-icons
    wofi
    waybar
    hyprpaper
    dconf
  ];

  fonts = [ nerd-fonts.jetbrains-mono ];

  cursorName = "phinger-cursors-light";
  cursorSize = 24;
  cursorPackage = phinger-cursors;

  # `nix-prefetch-git https://github.com/Rush/wayland-push-to-talk-fix.git`
  waylandPushToTalkFix = stdenv.mkDerivation rec {
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
    ++ systemTools ++ linuxEnvironment ++ fonts ++ [ waylandPushToTalkFix ];

  imports = [ ./autostart.nix ];

  fonts.fontconfig.enable = true;

  programs.waybar = {
    enable = true;

    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        modules-left = [ "hyprland/workspaces" ];
        modules-center = [ "clock" ];
        # modules-right = [ "pulseaudio" "battery" "network" ];
        clock = { format = "{:%a %d %b %I:%M %p}"; };

        # --- hyprland/workspaces config starts here ---
        "hyprland/workspaces" = {
          format = "{icon}";
          "format-icons" = {
            urgent = "";
            active = ""; # focused workspace on current monitor
            visible = ""; # focused workspace on other monitors
            default = "";
            empty = "";
            # empty = ""; # persistent (created by this plugin)
          };
          "all-outputs" = false; # recommended
        };
        # --- hyprland/workspaces config ends here ---
      };
    };

    style = ''
      * {
        font-family: "JetBrainsMono Nerd Font", monospace;
        font-size: 16px;
      }
      window#waybar {
        background-color: rgba(30, 30, 30, 0.95);
        color: white;
      }
    '';
  };

  home.file.".config/hypr/hyprpaper.conf".text = ''
    preload = /etc/nixos/home-manager/hypr/background.jpg
    wallpaper = ,/etc/nixos/home-manager/hypr/background.jpg
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

    cursorTheme = {
      name = cursorName;
      package = cursorPackage;
      size = cursorSize;
    };

    enable = true;
    gtk3.extraConfig = { "gtk-application-prefer-dark-theme" = true; };
    gtk4.extraConfig = { "gtk-application-prefer-dark-theme" = true; };
  };

  home.sessionVariables = {
    QT_QPA_PLATFORMTHEME = "qt6ct";
    QT_STYLE_OVERRIDE = "kvantum";
  };

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
    settings = import ./hypr/hyprland.conf;
  };

  # Sway
  wayland.windowManager.sway = {
    enable = true;
    wrapperFeatures.gtk = true; # Fixes common issues with GTK 3 apps
    config = rec {
      modifier = "Mod4";
      terminal = "kitty";
    };
  };

  # The state version is required and should stay at the version you
  # originally installed.
  home.stateVersion = "24.11";
}

{
  pkgs,
  inputs,
  system,
  ...
}:
with pkgs; let
  devTools = [cargo git];

  devPackages = [gnumake gcc pkg-config cmake jdk21 gradle nodejs_24 pnpm_9];

  gamingPackages = [discord prismlauncher];

  mediaPackages = [spotify xournalpp audacity];

  fileManager = [
    xfce.thunar
    xfce.tumbler # core thumbnail daemon
    xfce.thunar-archive-plugin
    kdePackages.ark
    xfce.thunar-media-tags-plugin
    ffmpegthumbnailer # video thumbnailer
  ];

  systemTools = [
    kdePackages.xwaylandvideobridge
    libqalculate
    vscode
    openvpn
    btop
    weylus
    scrcpy
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
    wlogout
    hyprsunset
    brightnessctl
    swaylock
    rofi-wayland
    waybar
    hyprpaper
    dconf
    networkmanagerapplet
  ];

  fonts = [nerd-fonts.jetbrains-mono];

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

    nativeBuildInputs = [pkg-config xorg.libX11];
    buildInputs = [libevdev pkgs.xdotool];
    installPhase = ''
      # Create the directory structure under $out
      mkdir -p $out/bin $out/share/applications

      # Copy the built binary
      cp push-to-talk $out/bin/push-to-talk
    '';
  };
in {
  home.packages =
    devTools
    ++ devPackages
    ++ gamingPackages
    ++ mediaPackages
    ++ systemTools
    ++ linuxEnvironment
    ++ fonts
    ++ fileManager
    ++ [waylandPushToTalkFix];

  programs.tmux = {
    enable = true;
    # aggressiveResize = true; -- Disabled to be iTerm-friendly
    baseIndex = 1;
    # Stop tmux+escape craziness.
    escapeTime = 0;
    # Force tmux to use /tmp for sockets (WSL2 compat)
    secureSocket = false;
    plugins = with pkgs; [
      tmuxPlugins.better-mouse-mode
      tmuxPlugins.gruvbox
      tmuxPlugins.sensible
      tmuxPlugins.vim-tmux-navigator
    ];
    keyMode = "vi";
    shortcut = "b";
    extraConfig = ''
      bind-key h select-pane -L
      bind-key j select-pane -D
      bind-key k select-pane -U
      bind-key l select-pane -R

      set -sg escape-time 50
      set -g default-terminal "screen-256color"
      set -as terminal-features ",xterm-256color:RGB"

      # Set new panes to open in current directory
      bind c new-window -c "#{pane_current_path}"
      bind '"' split-window -c "#{pane_current_path}"
      bind % split-window -h -c "#{pane_current_path}"

      set -g @tmux-gruvbox 'dark' # or 'light', 'dark-transparent', 'light-transparent'
    '';
  };

  #Kitty
  programs.kitty.enable = true;
  xdg.configFile."kitty/kitty.conf".source = ./kitty/kitty.conf;
  xdg.configFile."kitty/themes/gruvbox-material-dark-soft.conf".source = builtins.fetchurl {
    url = "https://raw.githubusercontent.com/kovidgoyal/kitty-themes/refs/heads/master/themes/GruvboxMaterialDarkSoft.conf";
    sha256 = "04azpbiv3vkqm0af0nl6ij9i0j2i95ij1rxxr2bb2cr3hh78x8yh";
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

    # nixd function for having nix shells
    # use the current shell
    initContent = ''
      nixd() {
        command nix develop "$@" -c "$SHELL"
      }

      set -o vi
      eval "$(starship init zsh)"
      export TERMINAL=kitty
      export EDITOR=nvim
      export VISUAL=nvim
    '';

    oh-my-zsh = {
      enable = true;

      plugins = ["git"];
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

  home.file.".config/nix/registry.json".text = let
    myShellFlakes = {
      comp3891 = {
        type = "path";
        path = "${inputs.self}/shells/comp3891";
      };
      progtemp = {
        type = "path";
        path = "${inputs.self}/templates";
      };
    };

    registryEntries = builtins.map (
      alias: let
        attrs = builtins.getAttr alias myShellFlakes;
      in {
        from = {
          type = "indirect";
          id = alias;
        };
        to = {
          type = attrs.type;
          path = attrs.path;
        };
      }
    ) (builtins.attrNames myShellFlakes);

    registryJson = builtins.toJSON {
      version = 2;
      flakes = registryEntries;
    };
  in
    registryJson;
}

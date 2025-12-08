{
  inputs,
  pkgs,
  ...
}: {
  home.packages = [
    pkgs.eza
    # inputs.ghostty.packages.${pkgs.stdenv.hostPlatform.system}.default # Ghostty
  ];

  programs.tmux = {
    enable = true;
    # aggressiveResize = true; -- Disabled to be iTerm-friendly
    baseIndex = 1;
    # Stop tmux+escape craziness.
    escapeTime = 0;
    # Force tmux to use /tmp for sockets (WSL2 compat)
    secureSocket = false;
    plugins = with pkgs.tmuxPlugins; [
      better-mouse-mode
      # gruvbox
      # catppuccin
      sensible
      vim-tmux-navigator
      resurrect
      continuum
    ];
    keyMode = "vi";
    shortcut = "b";
    extraConfig = ''
      set -g @continuum-save-interval '15'   # autosave every 15 minutes
      set -g @continuum-restore 'on'         # auto-restore on tmux start

      bind-key h select-pane -L
      bind-key j select-pane -D
      bind-key k select-pane -U
      bind-key l select-pane -R

      set -sg escape-time 50
      set -g default-terminal "screen-256color"
      set -as terminal-features ",xterm-256color:RGB"
      set-option -g default-shell "''${SHELL}"

      # Set new panes to open in current directory
      bind c new-window -c "#{pane_current_path}"
      bind '"' split-window -c "{pane_current_path}"
      bind % split-window -h -c "#{pane_current_path}"

      # set -g @tmux-gruvbox 'dark' # or 'light', 'dark-transparent', 'light-transparent'

      # Configure the catppuccin plugin
      # set -g @catppuccin_flavor "macchiato"
      # set -g @catppuccin_window_status_style "rounded"

      # Load catppuccin
      # run-shell ${pkgs.tmuxPlugins.catppuccin}/share/tmux-plugins/catppuccin/catppuccin.tmux

      # Make the status line pretty and add some modules
      set -g status-right-length 100
      set -g status-left-length 100
      set -g status-right ""
      set -g status-left ""

      # Window formatting
      set -g allow-rename off
      set -g automatic-rename off
      set -g window-status-format "#[fg=colour244]#I:#(basename #{pane_current_path})"
      set -g window-status-current-format "#[fg=colour81]#[bold]#I:#(basename #{pane_current_path})"

      # Snappy redraw so the text flips quickly
      set -g status-interval 1

      set -g window-status-format '#[fg=#{?client_prefix,#bea4fb,colour244}]#I#[fg=colour244]:#(basename #{pane_current_path})'
      set -g window-status-current-format '#[fg=#bea4fb]#[bold]#I:#(basename #{pane_current_path})'



# -------------------------------
# Warmer Theme (based on kitty)
# -------------------------------

# Main foreground/background
set -g status-fg "#a7aab0"
set -g status-bg "#2c2d30"

# Pane borders
set -g pane-border-style "fg=#5a5b5e"
set -g pane-active-border-style "fg=#68aee8"

# Message + prompts
set -g message-style "bg=#2c2d31,fg=#a7aab0"
set -g message-command-style "bg=#2c2d31,fg=#a7aab0"

# Mode (copy-mode)
set -g mode-style "bg=#57a5e5,fg=#2c2d30"

# Status line lengths
set -g status-left-length 100
set -g status-right-length 100

# Empty status content (you fill later)
set -g status-left ""
set -g status-right ""

# Window titles
set -g window-status-format "#[fg=#5a5b5e]#I:#(basename #{pane_current_path})"
set -g window-status-current-format "#[fg=#57a5e5,bold]#I:#(basename #{pane_current_path})"

# Optional: Use purple for active windows instead
# set -g window-status-current-format "#[fg=#bb70d2,bold]#I:#(basename #{pane_current_path})"

# Optional: Use orange
# set -g window-status-current-format "#[fg=#c49060,bold]#I:#(basename #{pane_current_path})"

# Optional: Use green
# set -g window-status-current-format "#[fg=#8fb573,bold]#I:#(basename #{pane_current_path})"




    '';
  };

  # Kitty
  programs.kitty.enable = true;
  xdg.configFile."kitty/kitty.conf".text = ''
    font_family      family="JetBrainsMono Nerd Font"
    bold_font        auto
    italic_font      auto
    bold_italic_font auto

    font_size 16.0

    include themes/onedark-warmer.conf
  '';

  xdg.configFile."kitty/themes/gruvbox-material-dark-soft.conf".source = builtins.fetchurl {
    url = "https://raw.githubusercontent.com/kovidgoyal/kitty-themes/refs/heads/master/themes/GruvboxMaterialDarkSoft.conf";
    sha256 = "04azpbiv3vkqm0af0nl6ij9i0j2i95ij1rxxr2bb2cr3hh78x8yh";
  };

  xdg.configFile."kitty/themes/onedark.conf".source = builtins.fetchurl {
    url = "https://raw.githubusercontent.com/GiuseppeCesarano/kitty-theme-OneDark/refs/heads/master/OneDark.conf";
    sha256 = "sha256:0ickbbk7j1ig66qp1rwxmpm8dd1kplijlhvdvk1s70xp8qr40a6z";
  };

  xdg.configFile."kitty/themes/onedark-warmer.conf".text = ''
    foreground #a7aab0
    background #2c2d30
    selection_foreground #2c2d30
    selection_background #a7aab0
    cursor #a7aab0
    cursor_text_color #2c2d30

    # UI colors
    active_border_color #68aee8
    inactive_border_color #2c2d31
    tab_bar_background #1b1c1e
    url_color #57a5e5

    # Normal colors
    color0  #101012
    color1  #de5d68
    color2  #8fb573
    color3  #dbb671
    color4  #57a5e5
    color5  #bb70d2
    color6  #51a8b3
    color7  #a7aab0

    # Bright colors
    color8  #5a5b5e
    color9  #de5d68
    color10 #8fb573
    color11 #dbb671
    color12 #57a5e5
    color13 #bb70d2
    color14 #51a8b3
    color15 #ffffff
  '';

  xdg.configFile."kitty/themes/catppuccin-macchiato.conf".source = builtins.fetchurl {
    url = "https://raw.githubusercontent.com/catppuccin/kitty/main/themes/macchiato.conf";
    sha256 = "sha256:1givl76kzc0ya70r4bvj5dnh01n7n4d2543xbmigwwdmd7879wfm";
  };

  # Ghostty (pkg already added above)
  # xdg.configFile."ghostty/config".text = ''
  #   theme = catppuccin-macchiato
  #   font-size = 16
  #   font-family = "JetBrainsMono Nerd Font"
  # '';

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
      gacps = ''
        git submodule foreach '
          git add .;
          git add -u;
          git commit -m "🙃" || true;
          git push || true
        ';
        git add .;
        git add -u;
        git commit -m "🙃" || true;
        git push
      '';
    };
    # nixd function for having nix shells
    # use the current shell
    initContent = ''
      nixd() {
        command nix develop "$@" -c "$SHELL"
      }
      set -o vi
      eval "$(starship init zsh)"

      alias ls='eza'

      export TERMINAL=kitty
      export EDITOR=nvim
      export VISUAL=nvim

      source ${pkgs.fzf}/share/fzf/completion.zsh
      source ${pkgs.fzf}/share/fzf/key-bindings.zsh
    '';

    oh-my-zsh = {
      enable = true;

      plugins = ["git"];
      theme = "robbyrussell";
    };
  };

  # Zoxide (cd replacement)
  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
    options = [
      "--cmd cd"
    ];
  };

  # fzf (mostly for zoxide)
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };
}

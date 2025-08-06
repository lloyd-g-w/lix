{pkgs, ...}: {
  home.packages = [
    pkgs.eza
  ];

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
      # tmuxPlugins.gruvbox
      tmuxPlugins.catppuccin
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
      set-option -g default-shell "''${SHELL}"

      # Set new panes to open in current directory
      bind c new-window -c "#{pane_current_path}"
      bind '"' split-window -c "{pane_current_path}"
      bind % split-window -h -c "#{pane_current_path}"

      # set -g @tmux-gruvbox 'dark' # or 'light', 'dark-transparent', 'light-transparent'

      # Configure the catppuccin plugin
      set -g @catppuccin_flavor "frappe"
      # set -g @catppuccin_window_status_style "rounded"

      # Load catppuccin
      run-shell ${pkgs.tmuxPlugins.catppuccin}/share/tmux-plugins/catppuccin/catppuccin.tmux

      # Make the status line pretty and add some modules
      set -g status-right-length 100
      set -g status-left-length 100
      set -g status-left ""

      set -g status-right "#{E:@catppuccin_status_application}"
      set -ag status-right "#{E:@catppuccin_status_session}"
      set -ag status-right "#{E:@catppuccin_status_uptime}"

      # Window formatting
      set -g allow-rename off
      set -g automatic-rename off
      set -g window-status-format "#[fg=colour244]#I:#(basename #{pane_current_path})"
      set -g window-status-current-format "#[fg=colour81]#[bold]#I:#(basename #{pane_current_path})"
    '';
  };

  #Kitty
  programs.kitty.enable = true;
  xdg.configFile."kitty/kitty.conf".text = ''
    font_family      family="JetBrainsMono Nerd Font"
    bold_font        auto
    italic_font      auto
    bold_italic_font auto

    font_size 16.0

    include themes/catppuccin-frappe.conf
  '';
  xdg.configFile."kitty/themes/gruvbox-material-dark-soft.conf".source = builtins.fetchurl {
    url = "https://raw.githubusercontent.com/kovidgoyal/kitty-themes/refs/heads/master/themes/GruvboxMaterialDarkSoft.conf";
    sha256 = "04azpbiv3vkqm0af0nl6ij9i0j2i95ij1rxxr2bb2cr3hh78x8yh";
  };
  xdg.configFile."kitty/themes/catppuccin-frappe.conf".source = builtins.fetchurl {
    url = "https://raw.githubusercontent.com/catppuccin/kitty/main/themes/frappe.conf";
    sha256 = "sha256:096szmcym5zi18qf1i72hqw4mjgkjzibcsf8yxwjv2zdqd7jx1kf";
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

      alias ls='eza'

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

  # Zoxide (cd replacement)
  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
    options = [
      "--cmd cd"
    ];
  };

  # fzf (mostly for zoxide)
  programs.fzf.enable = true;
  programs.fzf.enableZshIntegration = true;
}

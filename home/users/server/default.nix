{
  pkgs,
  lib,
  ...
}: {
  imports = [
    ../../../modules/home-manager/common.nix
    ../../../modules/home-manager/terminal.nix
  ];

  home.username = "lloyd";
  home.homeDirectory = "/home/lloyd";
  home.stateVersion = "24.11";

  home.packages = with pkgs; [
    # Utils
    unzip
    atool
    httpie
    evtest
    btop
    openvpn

    # Dev
    git
    gnumake
    gcc
    pkg-config
    cmake
    jdk21
    gradle
    nodejs_24
    pnpm_9
  ];

  # Start tmux automagically
  systemd.user.services."tmux-autostart" = {
    description = "Start tmux server and let continuum restore sessions";
    wantedBy = ["default.target"];
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.tmux}/bin/tmux start-server";
      # Create (or ensure) a dummy session so tmux actually starts;
      # continuum will replace it with your saved layout.
      ExecStartPost = "${pkgs.tmux}/bin/tmux has-session -t boot || ${pkgs.tmux}/bin/tmux new -d -s boot";
      # If you prefer forcing an immediate restore instead of waiting
      # for continuum's on-start restore, uncomment the next line:
      # ExecStartPost = "${pkgs.tmux}/bin/tmux run-shell ${pkgs.tmuxPlugins.resurrect}/share/tmux-plugins/resurrect/scripts/restore.sh";
      Restart = "on-failure";
    };
  };

  programs.tmux = {
    shortcut = lib.mkForce "a";
  };
}

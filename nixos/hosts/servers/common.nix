# Shared config for all servers: a function of the server name (a folder in
# this directory) returning a NixOS module. Used by ./default.nix.
name: {...}: let
  dir = ./. + "/${name}";
in {
  imports =
    [
      (dir + "/hardware-configuration.nix")
      ../../modules/common.nix
      # ../../modules/nvidia.nix
      ../../modules/users/lloyd.nix
      ../../modules/portainer.nix
    ]
    ++ builtins.filter builtins.pathExists [(dir + "/default.nix")];

  system.stateVersion = "24.11";
  networking.hostName = "server-${name}";

  # Bootloader is per machine: set it in ./<name>/default.nix

  nix.settings.trusted-users = [
    "root"
    "lloyd"
  ];

  # Start systemd services even without logging in.
  users.users.lloyd.linger = true;

  services.openssh = {
    enable = true;
    ports = [143];
    settings = {
      UseDns = true;
      # key-only login: both must be off, keyboard-interactive is a password prompt via PAM
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
    };
  };

  virtualisation.podman.enable = false;

  virtualisation.docker = {
    enable = true;

    daemon.settings = {
      dns = [
        "1.1.1.1"
        "8.8.8.8"
      ];
    };
  };

  virtualisation.oci-containers.backend = "docker";
  users.users.lloyd.extraGroups = ["docker"];

  # make persistent dirs for volumes
  # systemd.tmpfiles.rules = [
  #   "d /var/lib/nginx-proxy-manager 0755 root root - -"
  #   "d /var/lib/nginx-proxy-manager/data 0755 root root - -"
  #   "d /var/lib/nginx-proxy-manager/letsencrypt 0755 root root - -"
  # ];

  # run NPM as a declarative OCI container
  # virtualisation.oci-containers.containers.nginx-proxy-manager = {
  #   image = "jc21/nginx-proxy-manager:latest";
  #   ports = ["80:80" "81:81" "443:443" "25580:25580"];
  #   autoRemoveOnStop = false;
  #   volumes = [
  #     "/var/lib/nginx-proxy-manager/data:/data"
  #     "/var/lib/nginx-proxy-manager/letsencrypt:/etc/letsencrypt"
  #   ];
  #   extraOptions = ["--restart=unless-stopped"];
  # };

<<<<<<< HEAD
=======
  # set up wireguard server
  networking.wireguard = {
    enable = true;

    interfaces.wg0 = {
      ips = ["10.0.0.1/24"];

      listenPort = 51820;
      privateKeyFile = "/etc/wireguard/server.key";
      generatePrivateKeyFile = true;
      peers = [
        {
          publicKey = "tG3q4W+UJtJ1o5aNtJP30XE9RohPo3DuPy0mDUF/dQE=";
          allowedIPs = ["10.0.0.2/32"];
        }
      ];
    };
  };

  networking.nat = {
    enable = true;
    # externalInterface left unset (null): masquerade wg0 traffic out of
    # whatever interface the route uses, so this works on any machine
    internalInterfaces = ["wg0"];
  };
  networking.firewall.allowedUDPPorts = [51820];
  networking.firewall.extraForwardRules = ''
    iifname "wg0" oifname "eth0" accept
    iifname "eth0" oifname "wg0" accept
  '';
  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = true;
    "net.ipv6.conf.all.forwarding" = true;
  };

>>>>>>> 80bf38e141994991c455a00d03b25c6bedbb8fab
  networking.firewall.allowedTCPPorts = [443 2020 80 81 5173 7070 25580];
  programs.zsh.enable = true;
}

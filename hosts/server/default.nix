{...}: {
  imports = [
    ./hardware-configuration.nix
    ../../modules/nixos/common.nix
    ../../modules/nixos/users/lloyd.nix
  ];

  system.stateVersion = "24.11";
  networking.hostName = "server";

  # Bootloader.
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";
  boot.loader.grub.useOSProber = true;

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
      PasswordAuthentication = false;
    };
  };

  virtualisation.podman.enable = false;
  virtualisation.docker.enable = true;
  virtualisation.oci-containers.backend = "docker";
  users.users.lloyd.extraGroups = ["docker"];

  # make persistent dirs for volumes
  systemd.tmpfiles.rules = [
    "d /var/lib/nginx-proxy-manager 0755 root root - -"
    "d /var/lib/nginx-proxy-manager/data 0755 root root - -"
    "d /var/lib/nginx-proxy-manager/letsencrypt 0755 root root - -"
  ];

  # run NPM as a declarative OCI container
  virtualisation.oci-containers.containers.nginx-proxy-manager = {
    image = "jc21/nginx-proxy-manager:latest";
    ports = ["80:80" "81:81" "443:443"];
    autoRemoveOnStop = false;
    volumes = [
      "/var/lib/nginx-proxy-manager/data:/data"
      "/var/lib/nginx-proxy-manager/letsencrypt:/etc/letsencrypt"
    ];
    extraOptions = ["--restart=unless-stopped"];
  };

  # set up wireguard server
  networking.wireguard = {
    enable = true;

    interfaces.wg0 = {
      ips = ["10.0.0.1/24"];

      listenPort = 51820;
      privateKeyFile = "/etc/wireguard/server.key";
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
    externalInterface = "ens18";
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

  networking.firewall.allowedTCPPorts = [443 2020 80 81 5173 7070];
  programs.zsh.enable = true;
}

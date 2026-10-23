{
  virtualisation.docker.enable = true;

  virtualisation.oci-containers = {
    backend = "docker";
    containers.portainer = {
      image = "portainer/portainer-ce:lts";
      ports = [
        "9443:9443"
      ];
      volumes = [
        "/var/run/docker.sock:/var/run/docker.sock"
        "portainer_data:/data"
      ];
    };
  };

  networking.firewall.allowedTCPPorts = [9443];
}

# prigh-worker.nix
{pkgs, ...}: {
  systemd.services.prigh-worker = {
    wantedBy = ["multi-user.target"];
    after = ["network-online.target"];
    wants = ["network-online.target"];
    path = [pkgs.prigh "/run/wrappers" "/run/current-system/sw" "/etc/profiles/per-user/laptopserver"];
    serviceConfig = {
      User = "lloyd";
      EnvironmentFile = "/etc/prigh-worker.env"; # PRIGH_TOKEN=...
      Restart = "always";
      RestartSec = 10;
    };
    script = "exec prigh tool-host -connect $PRIGH_HOST:7790 -user $PRIGH_USER -token $PRIGH_TOKEN -cwd /home/lloyd";
  };
}

# TrueNAS storage for the arr stacks in ~/projects/lost (arr-cpu, arr-gpu).
# Import it on every host that runs one of them.
#
# TrueNAS only exports these shares to the hosts' NetBird IPs, so they are
# mounted over NetBird. They are mounted at boot (not automounted), because
# containers bind-mount the paths; the datasets nested under configs are
# crossed into automatically (NFSv4).
{
  lib,
  pkgs,
  ...
}: let
  truenas = "100.87.55.150"; # TrueNAS's NetBird IP
  shares = {
    "/mnt/truenas/configs" = "/mnt/main/configs";
    "/mnt/truenas/media" = "/mnt/main/media";
  };
in {
  # "netbird.service started" does not mean the tunnel is up: mounting right
  # after it fails with "Network is unreachable", and a failed mount is never
  # retried. So wait until TrueNAS's NFS port answers, however long it takes
  # (e.g. TrueNAS still booting after a power cut).
  systemd.services.truenas-nfs-ready = {
    description = "Wait for TrueNAS NFS over NetBird";
    after = ["netbird.service" "network-online.target"];
    wants = ["network-online.target"];
    serviceConfig = {
      Type = "oneshot";
      TimeoutStartSec = "infinity";
    };
    script = ''
      until ${pkgs.coreutils}/bin/timeout 3 ${pkgs.bash}/bin/bash -c ': </dev/tcp/${truenas}/2049' 2>/dev/null; do
        sleep 3
      done
    '';
  };

  fileSystems =
    lib.mapAttrs (_: path: {
      device = "${truenas}:${path}";
      fsType = "nfs";
      options = [
        "nfsvers=4"
        "_netdev"
        "nofail" # booting never depends on the NAS
        "x-systemd.requires=truenas-nfs-ready.service"
        "x-systemd.after=truenas-nfs-ready.service"
        "x-systemd.mount-timeout=60s"
      ];
    })
    shares;

  # Don't start docker (and its restart:unless-stopped containers) until the
  # shares are mounted. Otherwise apps start against the empty local
  # mountpoint directories: fresh configs, or an "empty" media library.
  # Note this holds back every container on the host while the NAS is down.
  systemd.services.docker.unitConfig.RequiresMountsFor = lib.attrNames shares;

  # Mirror TrueNAS's apps user/group (568), which owns the shares and which
  # the containers run as. lloyd joins the group to browse and edit them.
  users.groups.apps.gid = 568;
  users.users.apps = {
    uid = 568;
    group = "apps";
    isSystemUser = true;
  };
  users.users.lloyd.extraGroups = ["apps"];
}

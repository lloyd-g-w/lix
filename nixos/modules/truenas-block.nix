# App data (configs + SQLite databases) on a TrueNAS iSCSI LUN.
#
# NFS is fine for media, but SQLite over NFS stalls: every lock and fsync is a
# round trip to the NAS. A LUN is a block device, so ext4 runs on this host and
# locks/metadata stay local, while the data still lives on TrueNAS
# (zvol main/blocks/truenas-block, snapshotted there).
#
# Only ONE host may have the LUN logged in/mounted at a time, or ext4 gets
# corrupted. To move it: stop the containers, `umount /srv/appdata`,
# `iscsiadm -m node -U all`, then import this module on the new host and add
# that host's initiator name (below) to the TrueNAS initiator group.
#
# First-time setup (once, by hand, after checking the device in lsblk):
#   mkfs.ext4 -L truenas-block /dev/sdX
{config, ...}: let
  # TrueNAS's LAN IP, not NetBird: a block device should not depend on the tunnel.
  portal = "192.168.86.33:3260";
in {
  services.openiscsi = {
    enable = true;
    # Must be allowed by the TrueNAS target's initiator group.
    name = "iqn.2026-11.co.caduc:${config.networking.hostName}";
    discoverPortal = portal;
    # iscsi.service discovers the portal, then logs in at boot.
    enableAutoLoginOut = true;
    extraConfig = "node.startup = automatic";
  };

  fileSystems."/srv/appdata" = {
    device = "/dev/disk/by-label/truenas-block";
    fsType = "ext4";
    options = [
      "_netdev"
      "nofail" # booting never depends on the NAS
      "x-systemd.requires=iscsi.service"
      "x-systemd.after=iscsi.service"
      "x-systemd.device-timeout=60s"
    ];
  };

  # Don't start containers against the empty mountpoint.
  systemd.services.docker.unitConfig.RequiresMountsFor = ["/srv/appdata"];
}

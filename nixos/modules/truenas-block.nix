# App data (configs + SQLite databases) on a TrueNAS iSCSI LUN.
#
# NFS is fine for media, but SQLite over NFS stalls: every lock and fsync is a
# round trip to the NAS. A LUN is a block device, so ext4 runs on this host and
# locks/metadata stay local, while the data still lives on TrueNAS
# (a zvol under main/blocks, snapshotted there).
#
# A function: call it with the block's details and import the result, e.g.
#   imports = [
#     (import ../../../modules/truenas-block.nix {
#       name = "truenas-block";     # TrueNAS extent name = ext4 label
#       mountPoint = "/srv/appdata";
#     })
#   ];
#
# TrueNAS side, per block: zvol main/blocks/<name>, an extent/target <name>,
# and an initiator group allowing this host's initiator name:
#   iqn.2026-11.co.caduc:<hostname>
#
# Only ONE host may have a LUN logged in/mounted at a time, or ext4 gets
# corrupted. To move one: stop the containers, `umount <mountPoint>`,
# `iscsiadm -m node -U all`, then import it on the new host and allow that
# host's initiator name on TrueNAS.
#
# First-time setup (once, by hand, after checking the device in lsblk):
#   mkfs.ext4 -L <name> /dev/sdX
{
  name,
  mountPoint ? "/srv/appdata",
  # TrueNAS's LAN IP, not NetBird: a block device should not depend on the tunnel.
  portal ? "192.168.86.33:3260",
}: {config, ...}: {
  services.openiscsi = {
    enable = true;
    # Must be allowed by the TrueNAS target's initiator group.
    name = "iqn.2026-11.co.caduc:${config.networking.hostName}";
    discoverPortal = portal;
    # iscsi.service discovers the portal, then logs in at boot.
    enableAutoLoginOut = true;
    extraConfig = "node.startup = automatic";
  };

  fileSystems.${mountPoint} = {
    device = "/dev/disk/by-label/${name}";
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
  systemd.services.docker.unitConfig.RequiresMountsFor = [mountPoint];
}

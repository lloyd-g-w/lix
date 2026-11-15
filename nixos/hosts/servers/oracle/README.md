# server-oracle
Installed from Ubuntu with
[nixos-anywhere](https://github.com/nix-community/nixos-anywhere), which
**wipes the disk** (layout in `disko.nix`).

## Before installing

1. Back up everything on the server and copy it off: the `netbird_netbird_data`
   volume, `apps/laefik/acme/acme.json` (see lost's `apps/netbird/README.md`).
2. In Oracle's console, open **TCP 143** (SSH from now on) in the subnet's
   security list, next to 80/443 and the laefik/netbird ports that are
   already open. Check you can open the instance's Console connection (serial
   console): it is the way in if SSH fails.
3. SSH in by the public IP, not NetBird: NetBird goes down with the server.

Every public site is down from the install until laefik and netbird are
running again.

## Install

From the desktop, in this repo (the new files must be committed or at least
`git add`ed, or the flake can't see them):

```sh
mkdir -p /tmp/extra/var/lib/sops/age
install -m 600 ~/.sops/age/key /tmp/extra/var/lib/sops/age/key   # lec secrets on first boot

nix run github:nix-community/nixos-anywhere -- \
  --flake .#server-oracle \
  --build-on remote \
  --extra-files /tmp/extra \
  ubuntu@137.23.14.13

rm -rf /tmp/extra
```

`--build-on remote` builds on the server itself, since it is ARM and the
desktop is not. Afterwards SSH listens on **143**, and the server's host key
is new: remove the old one with `ssh-keygen -R 137.23.14.13`, and in
`~/.ssh/config` change `Host oracle` to `User lloyd` and `Port 143`.

## After installing

```sh
ssh -p 143 root@137.23.14.13 passwd lloyd     # once: lloyd needs it for sudo
ssh oracle
git clone https://github.com/lloyd-g-w/lost ~/projects/lost && cd ~/projects/lost
```

Restore netbird's data (from the backup copied up with scp), then start:

```sh
./lost compose netbird create
sudo tar xzf ~/netbird-backup.tar.gz -C /var/lib/docker/volumes/netbird_netbird_data/_data
mkdir -p apps/laefik/acme && install -m 600 ~/acme.json apps/laefik/acme/acme.json
./lost start netbird laefik
```

Then join this server's NetBird client to the restored server (a setup key
from the dashboard; it gets a new NetBird IP, which nothing points at):

```sh
sudo netbird up --management-url https://netbird.caduc.co --setup-key <key>
```

Other peers reconnect by themselves. Delete the backup files on the server
once everything works: they hold NetBird's keys.

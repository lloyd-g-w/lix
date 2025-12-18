# start and load your agent if you haven’t yet
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519
ssh-add -l   # confirm it’s listed

# then run nixos-rebuild using your SSH agent socket
sudo SSH_AUTH_SOCK=$SSH_AUTH_SOCK nixos-rebuild switch --flake .#server


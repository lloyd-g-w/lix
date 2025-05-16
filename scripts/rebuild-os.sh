#!/usr/bin/env bash
# Note: Must use path:. as it defaults to the git repo otherwise, and this doesn't work since we .gitignore the hardware config
sudo nixos-rebuild switch --flake path:.#lloyd

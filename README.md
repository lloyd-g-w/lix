# lix | nixos config

## Usage

To use the home-manager and nixos configurations provided by Lix, you must ensure that you use the 'path:' setting. For example, `sudo nixos-rebuild switch --flake path:.#<USER>@<HOST>`.

This is because nixos flakes require git tracking of all used files (there are workarounds but I am yet to find a good one), and `config.nix` should not be tracked as it can vary between machines.

> [!TIP]
> Use `nix flake init -t github:lloyd-g-w/lix#config` to generate a template `config.nix`

# lix | nixos config

## Usage

To use the home-manager and nixos configurations provided by Lix, you must ensure that you use the 'path:' setting. For example, `sudo nixos-rebuild switch --flake path:.#<USER>@<HOST>`.

This is because nixos flakes require git tracking of all used files (there are workarounds but I am yet to find a good one), and `config.nix` should not be tracked as it can vary between machines.

> [!TIP]
> Use `nix flake init -t github:lloyd-g-w/lix#config` to generate a template `config.nix`

If you are using the provided `lloyd` home-manager user, then you should have access to the [nix-helper](https://github.com/nix-community/nh) command `nh`. Further, if you correctly configured the `lix.dir` option, then you should be able to simply run `nh home switch` and `nh os switch` to update the configurations without providing other paths or options.

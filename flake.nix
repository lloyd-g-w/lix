{
  description = "NixOS Config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    lim = {
      url = "github:lloyd-g-w/lim";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprland.url = "github:hyprwm/Hyprland";

    split-monitor-workspaces = {
      url = "github:Duckonaut/split-monitor-workspaces";
      inputs.hyprland.follows = "hyprland";
    };

    anyrun = {
      url = "github:anyrun-org/anyrun";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs =
    inputs@{
      nixpkgs,
      home-manager,
      lim,
      anyrun,
      ...
    }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config = {
          allowUnfree = true;
        };
      };
    in
    {
      nixosConfigurations.lloyd = nixpkgs.lib.nixosSystem {
        system = system;
        modules = [
          (
            { config, pkgs, ... }:
            {
              nixpkgs.config.allowUnfree = true;
            }
          )
      ./configuration.nix

      # ❗ this is already required for homeConfigurations — good if it's there:
      {
        _module.args = {
          inherit inputs;
        };
      }
        ];
      };

      homeConfigurations.lloyd = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        #useGlobalPkgs = true;
        #useUserPackages = true;
        #backupFileExtension = "backup";
    extraSpecialArgs = { inherit inputs system; };
        modules = [
          ./home.nix
          lim.home-manager-module
          #anyrun.homeManagerModules.default
        ];
      };

    };
}

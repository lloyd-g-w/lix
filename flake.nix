{
  description = "NixOS Config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    hyprland.url = "github:hyprwm/Hyprland";
    split-monitor-workspaces = {
      url = "github:Duckonaut/split-monitor-workspaces";
      inputs.hyprland.follows = "hyprland";
    };
  };
  outputs = inputs@{ nixpkgs, home-manager, ... }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config = { allowUnfree = true; };
      };
    in {
      nixosConfigurations = {
        nixos = nixpkgs.lib.nixosSystem {
          system = system;
          modules = [
            ({ config, pkgs, ... }: { nixpkgs.config.allowUnfree = true; })
            ./configuration.nix
            home-manager.nixosModules.home-manager
            {
              home-manager.extraSpecialArgs = { inherit inputs pkgs system; };
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.lloyd = ./home.nix;
            }
          ];

        };

      };

    };
}

{
  description = "NixOS Config";

  nixConfig = {
    builders-use-substitutes = true;
    extra-substituters = ["https://walker.cachix.org"];
    extra-trusted-public-keys = [
      "walker.cachix.org-1:fG8q+uAaMqhsMxWjwvk0IMb4mFPFLqHjuvfwQxE4oJM="
    ];
  };

  inputs.self.submodules = true;
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    lim = {
      url = ./modules/lim;
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprland.url = "github:hyprwm/Hyprland";

    split-monitor-workspaces = {
      url = "github:Duckonaut/split-monitor-workspaces";
      inputs.hyprland.follows = "hyprland";
    };

    walker.url = "github:abenz1267/walker";
  };
  outputs = {
    nixpkgs,
    home-manager,
    lim,
  } @ inputs: {
    nixosConfigurations = {
      desktop = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {inherit inputs;};
        modules = [
          {
            _module.args.pkgs = import nixpkgs {
              system = "x86_64-linux";
              config.allowUnfree = true;
            };
          }
          ./hosts/desktop
        ];
      };

      laptop = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {inherit inputs;};
        modules = [
          {
            _module.args.pkgs = import nixpkgs {
              system = "x86_64-linux";
              config.allowUnfree = true;
            };
          }
          ./hosts/laptop
        ];
      };
    };

    homeConfigurations = {
      lloyd = home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs {
          system = "x86_64-linux";
          config.allowUnfree = true;
        };
        extraSpecialArgs = {inherit inputs;};
        modules = [
          ./home/users/lloyd
          lim.homeManagerModules.default
          inputs.walker.homeManagerModules.default
        ];
      };
    };
  };
}

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

    # For lim
    flake-utils.url = "github:numtide/flake-utils";

    lim = {
      url = ./modules/home-manager/lim;
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };

    hyprland.url = "github:hyprwm/Hyprland/v0.50.0";

    hy3 = {
      url = "github:outfoxxed/hy3?ref=hl0.50.0";
      inputs.hyprland.follows = "hyprland";
    };

    split-monitor-workspaces = {
      url = "github:Duckonaut/split-monitor-workspaces/c88e49f8cc5bbc1f3daec5e11116494a7b9e62ed";
      inputs.hyprland.follows = "hyprland";
    };

    walker.url = "github:abenz1267/walker";
  };
  outputs = {
    nixpkgs,
    home-manager,
    lim,
    ...
  } @ inputs: {
    nixosConfigurations = {
      desktop = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {inherit inputs;};
        modules = [
          {nixpkgs.config.allowUnfree = true;}
          ./hosts/desktop
        ];
      };

      laptop = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {inherit inputs;};
        modules = [
          {nixpkgs.config.allowUnfree = true;}
          ./hosts/laptop
        ];
      };

      server = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {inherit inputs;};
        modules = [
          {nixpkgs.config.allowUnfree = true;}
          ./hosts/server
        ];
      };
    };

    homeConfigurations = {
      "lloyd@desktop" = home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs {
          system = "x86_64-linux";
          config.allowUnfree = true;
        };
        extraSpecialArgs = {inherit inputs;};
        modules = [
          ./home/users/lloyd/desktop.nix
          lim.homeManagerModules.default
          inputs.walker.homeManagerModules.default
        ];
      };

      "lloyd@laptop" = home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs {
          system = "x86_64-linux";
          config.allowUnfree = true;
        };
        extraSpecialArgs = {inherit inputs;};
        modules = [
          ./home/users/lloyd/laptop.nix
          lim.homeManagerModules.default
          inputs.walker.homeManagerModules.default
        ];
      };

      "server" = home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs {
          system = "x86_64-linux";
          config.allowUnfree = true;
        };
        extraSpecialArgs = {inherit inputs;};
        modules = [
          ./home/users/server
          lim.homeManagerModules.default
        ];
      };
    };
  };
}

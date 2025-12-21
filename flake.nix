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

    ghostty.url = "github:ghostty-org/ghostty";

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

    elephant.url = "github:abenz1267/elephant";

    walker = {
      url = "github:abenz1267/walker";
      inputs.elephant.follows = "elephant";
    };

    mango = {
      url = "github:DreamMaoMao/mango";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    latus = {
      url = ./pkgs/latus;
    };
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    lim,
    mango,
    ...
  } @ inputs: let
    system = "x86_64-linux";
  in {
    # ─────────────────────────────────────────────────────────────
    # Overlay: expose latus as pkgs.latus everywhere
    # ─────────────────────────────────────────────────────────────
    overlays.default = final: prev: {
      latus = inputs.latus.packages.${final.system}.default;
    };

    # ─────────────────────────────────────────────────────────────
    # NixOS configurations
    # ─────────────────────────────────────────────────────────────
    nixosConfigurations = {
      desktop = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = {inherit inputs;};
        modules = [
          {nixpkgs.overlays = [self.overlays.default];}
          {nixpkgs.config.allowUnfree = true;}
          mango.nixosModules.mango
          ./hosts/desktop
        ];
      };

      laptop = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = {inherit inputs;};
        modules = [
          {nixpkgs.overlays = [self.overlays.default];}
          {nixpkgs.config.allowUnfree = true;}
          mango.nixosModules.mango
          ./hosts/laptop
        ];
      };

      server = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = {inherit inputs;};
        modules = [
          {nixpkgs.overlays = [self.overlays.default];}
          {nixpkgs.config.allowUnfree = true;}
          mango.nixosModules.mango
          ./hosts/server
        ];
      };

      desktop-server = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = {inherit inputs;};
        modules = [
          {nixpkgs.overlays = [self.overlays.default];}
          {nixpkgs.config.allowUnfree = true;}
          mango.nixosModules.mango
          ./hosts/desktop-server
        ];
      };
    };

    # ─────────────────────────────────────────────────────────────
    # Home Manager configurations
    # ─────────────────────────────────────────────────────────────
    homeConfigurations = {
      "lloyd@desktop" = home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
          overlays = [self.overlays.default];
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
          inherit system;
          config.allowUnfree = true;
          overlays = [self.overlays.default];
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
          inherit system;
          config.allowUnfree = true;
          overlays = [self.overlays.default];
        };
        extraSpecialArgs = {inherit inputs;};
        modules = [
          ./home/users/server
          lim.homeManagerModules.default
        ];
      };

      "desktop-server" = home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
          overlays = [self.overlays.default];
        };
        extraSpecialArgs = {inherit inputs;};
        modules = [
          ./home/users/desktop-server
          lim.homeManagerModules.default
        ];
      };
    };
  };
}

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
  outputs = inputs @ {
    nixpkgs,
    home-manager,
    lim,
    ...
  }: let
    system = "x86_64-linux";
    pkgs = import nixpkgs {
      inherit system;
      config = {
        allowUnfree = true;
      };
    };
  in {
    nixosConfigurations.lloyd = nixpkgs.lib.nixosSystem {
      system = system;
      modules = [
        (
          {
            config,
            pkgs,
            ...
          }: {
            nixpkgs.config.allowUnfree = true;
          }
        )
        ./configuration.nix
        {_module.args = {inherit inputs;};}
      ];
    };

    homeConfigurations.lloyd = home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      extraSpecialArgs = {inherit inputs system;};
      modules = [
        ./home.nix
        lim.homeManagerModules.default
        inputs.walker.homeManagerModules.default
      ];
    };
  };
}

{
  description = "NixOS Config";

  nixConfig = {
    builders-use-substitutes = true;
    extra-substituters = ["https://anyrun.cachix.org"];
    extra-trusted-public-keys = [
      "anyrun.cachix.org-1:pqBobmOjI7nKlsUMV25u9QHa9btJK65/C8vnO3p346s="
    ];
  };

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
  outputs = inputs @ {
    nixpkgs,
    home-manager,
    lim,
    anyrun,
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
        lim.home-manager-module
      ];
    };
  };
}

{
  inputs,
  self,
  config,
  ...
}: let
  mkHome = system: modules:
    inputs.home-manager.lib.homeManagerConfiguration {
      pkgs = import inputs.nixpkgs {
        inherit system;
        config.allowUnfree = true;

        overlays = [
          self.overlays.default
        ];
      };

      # this injects lix as an arg in all modules
      extraSpecialArgs = {
        inherit inputs self;
        lix = config.lix;
      };

      # adds lix sharedModules to config
      modules = modules ++ config.lix.home.sharedModules;
    };
in {
  flake.homeConfigurations = {
    "lloyd@desktop" = mkHome "x86_64-linux" [./users/lloyd/desktop.nix];
    "lloyd@laptop" = mkHome "x86_64-linux" [./users/lloyd/laptop.nix];
  };
}

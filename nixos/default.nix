{
  inputs,
  self,
  config,
  ...
}: let
  mkHost = system: modules:
    inputs.nixpkgs.lib.nixosSystem {
      inherit system;

      # this injects lix as an arg in all modules
      specialArgs = {
        inherit inputs self;
        lix = config.lix;
      };

      # adds lix sharedModules to config
      modules =
        modules
        ++ config.lix.os.sharedModules;
    };
in {
  flake.nixosConfigurations = {
    desktop = mkHost "x86_64-linux" [./hosts/desktop];
  };
}

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
        ++ config.lix.os.sharedModules
        ++ [{nixpkgs.overlays = [self.overlays.default];}];
    };

  # { "server-<folder>" = module; } from ./hosts/servers
  # The architecture comes from each server's nixpkgs.hostPlatform (set in its
  # hardware-configuration.nix), so x86 and ARM servers can sit side by side.
  servers = builtins.mapAttrs (_: module: mkHost null [module]) (import ./hosts/servers);
in {
  flake.nixosConfigurations =
    {
      desktop = mkHost "x86_64-linux" [./hosts/desktop];
      laptop = mkHost "x86_64-linux" [./hosts/laptop];
    }
    // servers;
}

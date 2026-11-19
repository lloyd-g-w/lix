{
  inputs,
  self,
  ...
}: let
in {
  flake.overlays.default = final: prev: {
    latus = inputs.latus.packages.${prev.stdenv.hostPlatform.system}.default;
    lix.edit = self.packages.${prev.stdenv.hostPlatform.system}.edit;
    zen-browser = inputs.zen-browser.packages.${prev.stdenv.hostPlatform.system}.default;
    prigh = inputs.prigh.packages.${prev.stdenv.hostPlatform.system}.default;
  };
}

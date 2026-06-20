{
  inputs,
  self,
  ...
}: let
in {
  flake.overlays.default = final: prev: {
    latus = inputs.latus.packages.${prev.stdenv.hostPlatform.system}.default;
    lix.dev = self.packages.${prev.stdenv.hostPlatform.system}.dev;
    zen-browser = inputs.zen-browser.packages.${prev.stdenv.hostPlatform.system}.default;
    typst_15 = import ./typst_15;
  };
}

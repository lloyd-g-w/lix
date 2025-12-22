{
  inputs,
  self,
  ...
}: {
  flake.overlays.default = final: prev: {
    latus = inputs.latus.packages.${prev.stdenv.hostPlatform.system}.default;
    lix.dev = self.packages.${prev.stdenv.hostPlatform.system}.dev;
  };
}

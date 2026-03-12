{
  inputs,
  self,
  ...
}: let
  # anytypeFix = import ./anytype-fix.nix;
in {
  flake.overlays.default = final: prev:
  # (anytypeFix final prev)
  # //
  {
    latus = inputs.latus.packages.${prev.stdenv.hostPlatform.system}.default;
    lix.dev = self.packages.${prev.stdenv.hostPlatform.system}.dev;
  };
}

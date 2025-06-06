{
  description = "Generate templates for several prog langs";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = {
    self,
    nixpkgs,
    ...
  }: let
    system = "x86_64-linux";
    pkgs = import nixpkgs {inherit system;};
  in {
    apps.${system}.comp4128 = pkgs.writeShellScriptBin "comp4128" ''
      ${./comp4128.sh}
    '';
  };
}

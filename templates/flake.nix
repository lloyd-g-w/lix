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
    # Define a single "default" app for x86_64-linux
    apps.${system}.default = pkgs.writeShellScriptBin "cpp-template" ''
      ${./cpp-template.sh}
    '';
  };
}

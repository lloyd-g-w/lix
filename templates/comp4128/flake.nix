{
  description = "A C++ template generator for COMP4128";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = nixpkgs.legacyPackages.${system};

      templateFile = ./comp4128.cpp;

      comp4128-script = pkgs.writeShellApplication {
        name = "comp4128";
        runtimeInputs = [pkgs.bash pkgs.coreutils]; # for `cat`

        # Read the contents of the shell script and replace the placeholder.
        text =
          builtins.replaceStrings
          ["@template_path@"]
          ["${templateFile}"]
          (builtins.readFile ./comp4128.sh);
      };
    in {
      apps.default = {
        type = "app";
        program = "${comp4128-script}/bin/comp4128";
      };

      packages.default = comp4128-script;
    });
}

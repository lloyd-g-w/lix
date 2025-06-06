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
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = nixpkgs.legacyPackages.${system};

        # The C++ template file
        templateFile = ./comp4128.cpp;

        # The main script that will be built
        comp4128-script = pkgs.writeShellApplication {
          name = "comp4128";
          runtimeInputs = [pkgs.bash];
          text = ''
            #!${pkgs.bash}/bin/bash
            template_file="${templateFile}"
            destination_file=""

            if [ -z "$1" ]; then
              destination_file="main.cpp"
            else
              destination_file="$1"
              # If the user didn’t supply a ".cpp" suffix, append it
              case "$destination_file" in
                *.cpp) ;;
                *) destination_file="''${destination_file}.cpp" ;;
              esac
            fi


            if [ ! -f "$template_file" ]; then
              echo "Error: Template file not found at '$template_file'"
              exit 1
            fi

            # --- Copy the Template to the Destination File ---
            cp "$template_file" "$destination_file"

            echo "Constructed COMP4128 file: $destination_file"
          '';
        };
      in {
        # Package that can be installed or used as a build input
        # build with `nix build .#`
        packages = {
          default = comp4128-script;
        };

        # App that can be run directly
        # run with `nix run . -- <filename>`
        apps = {
          default = {
            type = "app";
            program = "${comp4128-script}/bin/comp4128";
          };
        };

        # Template files that can be used by other flakes
        # useful for composing flakes
        templates = {
          default = self;
          comp4128 = {
            path = ./.;
            description = "COMP4128 Competitive Programming Template";
          };
        };
      }
    );
}

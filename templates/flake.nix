{
  description = "A collection of all my project templates";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # Import the comp4128 flake from the subdirectory
    comp4128-template.url = "path:./templates/comp4128"; # Adjust path if needed
  };

  outputs = {
    self,
    nixpkgs,
    comp4128-template,
    ...
  } @ inputs: {
    apps.x86_64-linux = {
      comp4128 = {
        type = "app";
        program = "${comp4128-template.packages.x86_64-linux.default}/bin/comp4128";
      };
    };
  };
}

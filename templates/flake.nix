{
  description = "A collection of all my project templates";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    comp4128-template.url = "path:./comp4128";
  };

  outputs = {comp4128-template, ...} @ inputs: {
    apps.x86_64-linux = {
      comp4128 = {
        type = "app";
        program = "${comp4128-template.packages.x86_64-linux.default}/bin/comp4128";
      };
    };
  };
}

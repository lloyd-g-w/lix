{pkgs, ...}:
pkgs.recurseIntoAttrs {
  oxcaml = pkgs.callPackage ./oxcaml.nix {};
  ocamlformat = pkgs.callPackage ./ocaml-format.nix {};
  # ocaml-lsp = pkgs.callPackage ./ocaml-lsp.nix {};
}

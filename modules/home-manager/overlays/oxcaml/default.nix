{pkgs, ...}:
pkgs.recurseIntoAttrs {
  oxcaml = pkgs.callPackage ./oxcaml.nix {};
  ocamlformat = pkgs.callPackage ./ocamlformat.nix {};
  ocaml-lsp = pkgs.callPackage ./ocaml-lsp.nix {};
}

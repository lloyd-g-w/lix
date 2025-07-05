{pkgs, ...}: let
  res = {
    oxcaml = pkgs.callPackage ./oxcaml.nix {};
    # ocamlformat = pkgs.callPackage ./ocamlformat.nix {};
    ocaml-lsp = pkgs.callPackage ./ocaml-lsp.nix {
      inherit (res) oxcaml;
    };
  };
in
  pkgs.recurseIntoAttrs res

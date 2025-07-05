{
  lib,
  stdenv,
  fetchurl,
  ocamlPackages,
  ...
}:
ocamlPackages.buildDunePackage rec {
  pname = "ocaml-lsp-server";
  version = "1.19.0+ox";

  src = fetchurl {
    url = "https://github.com/oxcaml/ocaml-lsp/archive/c0a3e5d5fdffa5fc362c0c8190e4794cd731d09a.tar.gz";
    sha256 = "sha256-fThHL6aMaqKDlB8V/kFV0EFkkE2yqXQJBLZ7Yv9EooI=";
  };

  # Dune is used for both building and setup
  duneInputs = with ocamlPackages; [
    yojson
    base
    lsp
    jsonrpc
    re
    ppx_yojson_conv_lib
    dune-rpc
    chrome-trace
    dyn
    stdune
    fiber
    xdg
    ordering
    dune-build-info
    spawn
    astring
    camlp-streams
    ppx_expect
    ocamlformat
    ocamlc-loc
    pp
    csexp
    ocamlformat-rpc-lib
    odoc
    merlin-lib
    async
    cmarkit
    re2
    odoc-parser
  ];

  # For generating documentation
  doDoc = true;

  meta = with lib; {
    description = "LSP Server for OCaml";
    homepage = "https://github.com/ocaml/ocaml-lsp";
    maintainers = [];
    platforms = platforms.unix;
    longDescription = ''An LSP server for OCaml.'';
  };
}

{pkgs, ...}:
pkgs.stdenv.mkDerivation {
  pname = "ocaml-lsp";
  version = "unstable-2024-03-26";

  src = pkgs.fetchFromGitHub {
    owner = "oxcaml";
    repo = "ocaml-lsp";
    sha256 = "sha256-MJWrcuzJVoHM00ZRgFB5vjnJO0KfYXISPRByQlqFJco=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = with pkgs; [
    autoconf
  ];

  buildInputs = with pkgs; [
    oxcaml.oxcaml
    dune_3
    ocamlPackages.menhir
    ocamlPackages.sedlex
  ];

  doCheck = false;

  # By not specifying configurePhase, buildPhase, or installPhase, we let the
  # standard environment take over, which will run the standard sequence:
  # ./configure --prefix=$out
  # make
  # make install
  # This is the intended build process for this project.

  meta = with pkgs.lib; {
    description = "Oxcaml LSP";
    homepage = "https://github.com/oxcaml/ocaml-lsp";
    license = licenses.mit;
    platforms = pkgs.ocaml.meta.platforms or [];
  };
}

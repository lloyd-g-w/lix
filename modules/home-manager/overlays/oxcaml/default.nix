let
  pkgs = import <nixpkgs> {};
in
  pkgs.stdenv.mkDerivation {
    pname = "oxcaml";
    version = "unstable-2024-03-26";

    src = pkgs.fetchFromGitHub {
      owner = "oxcaml";
      repo = "oxcaml";
      rev = "5.3.0";
      sha256 = "sha256-MJWrcuzJVoHM00ZRgFB5vjnJO0KfYXISPRByQlqFJco=";
      fetchSubmodules = true;
    };

    nativeBuildInputs = with pkgs; [
      autoconf
    ];

    buildInputs = with pkgs; [
      ocaml
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
      description = "A new implementation of the OCaml programming language";
      homepage = "https://github.com/oxcaml/oxcaml";
      license = licenses.mit;
      platforms = pkgs.ocaml.meta.platforms or [];
    };
  }


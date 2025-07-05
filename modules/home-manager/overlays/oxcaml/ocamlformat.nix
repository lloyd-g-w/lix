{
  pkgs,
  oxcaml,
  ...
}:
pkgs.stdenv.mkDerivation {
  pname = "ocamlformat";
  version = "0.4";

  src = pkgs.fetchFromGitHub {
    owner = "oxcaml";
    repo = "ocamlformat";
    rev = "0.4";
    sha256 = "sha256-AYMHDdtUvGozeYiQPX6v8MEdSv4EQksa4YAjfjfIInc=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = with pkgs; [
    autoconf
  ];

  buildInputs = with pkgs; [
    oxcaml
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
    description = "Oxcaml formatter";
    homepage = "https://github.com/oxcaml/ocamlformat";
    license = licenses.mit;
    platforms = pkgs.ocaml.meta.platforms or [];
  };
}

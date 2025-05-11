{ pkgs ? import <nixpkgs> { } }:

pkgs.mkShell {
  buildInputs = [ pkgs.openjdk17 ];

  shellHook = ''
    echo "Java version:"
    java -version
  '';
}

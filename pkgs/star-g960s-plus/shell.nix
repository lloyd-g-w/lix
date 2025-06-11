# shell.nix
let
  pkgs = import <nixpkgs> {};

  myDriver = pkgs.callPackage ./default.nix {
    qtx11extras = pkgs.qt5.qtx11extras;
    wrapQtAppsHook = pkgs.qt5.wrapQtAppsHook;
    libGL = pkgs.libGL;
    glibc = pkgs.glibc;
  };
in
  pkgs.mkShell {
    buildInputs = [
      myDriver
    ];
  }

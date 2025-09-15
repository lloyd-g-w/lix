{
  description = "A Nix shell for COMP9242 sel4.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    legacy-nixpkgs = {
      url = "github:NixOS/nixpkgs/release-19.09";
      flake = false;
    };
  };

  outputs = {
    nixpkgs,
    legacy-nixpkgs,
    ...
  }: let
    system = "x86_64-linux";
    pkgs = import nixpkgs {inherit system;};
    legacyPkgs = import legacy-nixpkgs {inherit system;};

    os161Utils = pkgs.stdenv.mkDerivation {
      pname = "os161-utils";
      version = "2.0.8-4";

      src = pkgs.fetchurl {
        url = "http://www.cse.unsw.edu.au/~cs3231/os161-files/os161-utils_2.0.8-4.deb";
        sha256 = "0blnhzkj1m5k3d5x615gqr32vsdz2zfw4484phf5r4jmkf4f9hik";
      };

      nativeBuildInputs = [pkgs.dpkg pkgs.autoPatchelfHook];

      buildInputs = [
        pkgs.glibc
        legacyPkgs.ncurses
        pkgs.libmpc
        pkgs.mpfr
        pkgs.gmp
      ];

      unpackPhase = ''
        mkdir -p $out
        dpkg-deb -x "$src" "$out"
      '';

      installPhase = ''
        find $out/usr/local/bin -type f -exec chmod +x {} +
      '';

      dontStrip = true;
    };
  in {
    devShells.${system}.default = pkgs.mkShell {
      buildInputs = with pkgs; [
        # C/C++ build tools
        cmake
        ccache
        ninja

        # Libraries and utilities
        libxml2
        ncurses
        curl
        git
        doxygen
        dtc # device-tree-compiler
        xxd # from the vim package
        ubootTools

        # Python environment
        python3
        protobuf
      ];

      shellHook = ''
        export SHELL="${pkgs.zsh}/bin/zsh"
        exec zsh

        echo "Done."
      '';
    };
  };
}

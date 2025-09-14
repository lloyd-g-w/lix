{
  description = "A Nix-based development environment for seL4.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs {
        inherit system;
      };

      python-with-packages = pkgs.python3.withPackages (ps:
        with ps; [
          setuptools
          sel4-deps
        ]);
    in {
      devShells.default = pkgs.mkShell {
        packages = with pkgs; [
          # Base build tools
          gcc
          gdb
          make
          cmake
          ccache
          ninja
          cmakeCurses

          # Python
          python-with-packages

          # Other tools
          libxml2
          ncurses
          curl
          git
          doxygen
          dtc
          ubootTools
          protobuf

          # Cross-compilers
          # ARM 32-bit
          arm-linux-gnueabihf-binutils
          arm-linux-gnueabihf-gcc

          # ARM 64-bit
          aarch64-linux-gnu-binutils
          aarch64-linux-gnu-gcc

          # LaTeX for manual
          texlive.combined.scheme-full
        ];

        shellHook = ''
          echo "Entering seL4 development environment..."
          # Create a Python virtual environment
          python -m venv .venv
          source .venv/bin/activate
          echo "Python virtual environment activated."
        '';
      };
    });
}

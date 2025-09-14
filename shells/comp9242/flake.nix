{
  description = "A definitive Nix-based development environment for seL4.";

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
      pkgs = import nixpkgs {inherit system;};

      # Create dedicated package sets for each cross-compilation target.
      pkgs_arm32 = import nixpkgs {
        inherit system;
        crossSystem = {config = "armv7l-linux-gnueabihf";};
      };
      pkgs_aarch64 = import nixpkgs {
        inherit system;
        crossSystem = {config = "aarch64-linux-gnu";};
      };

      # Use a stable Python version.
      python = pkgs.python312;

      # ⭐ Create a Python environment with the seL4 dependencies listed directly.
      # This is simpler and more reliable than fetching the sel4-deps meta-package.
      python-with-packages = python.withPackages (ps:
        with ps; [
          aenum
          future
          jinja2
          ply
          pyelftools
          pyserial
          six
        ]);
    in {
      devShells.default = pkgs.mkShell {
        packages = with pkgs; [
          # Shell
          zsh

          # Base build tools from the seL4 documentation
          gcc
          gdb
          gnumake
          cmake
          ccache
          ninja
          cmakeCurses
          doxygen
          dtc
          ubootTools
          protobuf
          vim # for xxd

          # Python environment with seL4 dependencies
          python-with-packages

          # Other tools
          libxml2
          ncurses
          curl
          git

          # Cross-compilers from the dedicated package sets
          pkgs_arm32.gcc
          pkgs_aarch64.gcc
        ];

        shellHook = ''
          echo "Entering seL4 development environment..."

          # Create and activate a Python virtual environment
          if [ ! -d ".venv" ]; then
            echo "Creating Python virtual environment..."
            python -m venv .venv
          fi
          source .venv/bin/activate
          echo "Python virtual environment activated."

          # If the current shell is not Zsh, switch to it
          if [ -z "$ZSH_VERSION" ]; then
            echo "Switching to Zsh..."
            export SHELL="${pkgs.zsh}/bin/zsh"
            exec zsh
          fi
        '';
      };
    });
}

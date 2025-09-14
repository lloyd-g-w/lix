{
  description = "Dev shell for COMP9242";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs {inherit system;};
      py = pkgs.python3;
    in {
      devShells.default = pkgs.mkShell {
        name = "sel4-dev";

        packages = with pkgs; [
          # base toolchain / build utils
          gcc
          gnumake
          pkg-config
          cmake
          ninja
          ccache
          git
          curl
          doxygen
          libxml2 # provides xmllint
          ncurses
          dtc # device-tree-compiler
          ubootTools
          vim # provides xxd
          protobuf # protoc
          python3
          python3Packages.pip
          python3Packages.virtualenv
          python3Packages.protobuf
          git-repo
          repo # Google's 'repo' tool
          qemu # system emulators (arm/x86/etc)
        ];

        # ccache by default
        CCACHE_DIR = ".ccache";

        # Create & activate a venv and install sel4-deps (host-only py deps)
        shellHook = ''
          echo "🔧 seL4 dev shell: setting up Python venv..."
          if [ ! -d .venv ]; then
            ${py.interpreter} -m venv .venv
          fi
          . .venv/bin/activate
          pip install --upgrade pip setuptools
          pip install --upgrade sel4-deps
          echo "✅ Python deps ready (sel4-deps installed)."
          echo "Tip: For cross builds, pass -DCROSS_COMPILER_PREFIX=<triplet>- to init-build.sh"
        '';
      };
    });
}

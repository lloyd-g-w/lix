{
  description = "seL4 dev shell (older cross toolchain + Ninja/CMake + Python deps)";

  # Pin to 23.11 to avoid binutils 2.44 copy-reloc error
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";

  outputs = {
    self,
    nixpkgs,
  }: let
    systems = ["x86_64-linux" "aarch64-linux"];
    forAllSystems = f:
      builtins.listToAttrs (map (system: {
          name = system;
          value = f system;
        })
        systems);
  in {
    devShells = forAllSystems (system: let
      pkgs = import nixpkgs {inherit system;};

      # Cross toolchains (23.11 gives older binutils/gcc)
      aarch64_gcc = pkgs.pkgsCross.aarch64-embedded.buildPackages.gcc;
      aarch64_binutils = pkgs.pkgsCross.aarch64-embedded.buildPackages.binutils;

      riscv_gcc = pkgs.pkgsCross.riscv64-embedded.buildPackages.gcc;
      riscv_binutils = pkgs.pkgsCross.riscv64-embedded.buildPackages.binutils;

      arm_gcc = pkgs.gcc-arm-embedded; # arm-none-eabi-*
    in {
      default = pkgs.mkShell {
        packages =
          (with pkgs; [
            # build tools
            cmake
            ninja
            ccache
            cmakeCurses

            # your apt-mapped utils
            libxml2
            ncurses
            curl
            git
            doxygen
            dtc
            xxd
            ubootTools
            protobuf
            qemu_full

            # python (venv created in shellHook) with pip + setuptools
            (python3.withPackages (ps: with ps; [pip setuptools]))
          ])
          ++ [
            aarch64_gcc
            aarch64_binutils
            riscv_gcc
            riscv_binutils
            arm_gcc
          ];

        # Default to AArch64; you can switch inside the shell (see helper)
        env = {
          CROSS_COMPILER_PREFIX = "aarch64-none-elf-";
          CC = "aarch64-none-elf-gcc";
          CXX = "aarch64-none-elf-g++";
          LD = "aarch64-none-elf-ld";
          AR = "aarch64-none-elf-ar";
        };

        shellHook = ''
          set -euo pipefail
          alias python=python3

          # Helper to change target without leaving the shell
          sel4-target () {
            case "''${1-}" in
              aarch64)
                export CROSS_COMPILER_PREFIX=aarch64-none-elf-
                export CC=aarch64-none-elf-gcc CXX=aarch64-none-elf-g++ LD=aarch64-none-elf-ld AR=aarch64-none-elf-ar ;;
              arm)
                export CROSS_COMPILER_PREFIX=arm-none-eabi-
                export CC=arm-none-eabi-gcc CXX=arm-none-eabi-g++ LD=arm-none-eabi-ld AR=arm-none-eabi-ar ;;
              riscv)
                export CROSS_COMPILER_PREFIX=riscv64-none-elf-
                export CC=riscv64-none-elf-gcc CXX=riscv64-none-elf-g++ LD=riscv64-none-elf-ld AR=riscv64-none-elf-ar ;;
              *)
                echo "Usage: sel4-target aarch64|arm|riscv" >&2; return 1 ;;
            esac
            echo "Switched to $CROSS_COMPILER_PREFIX (CC=$CC)"
          }

          # --- Python deps for seL4 builds (project-local venv) ---
          VENV_DIR="$PWD/.venv-sel4"
          if [ ! -d "$VENV_DIR" ]; then
            echo "Creating Python venv at $VENV_DIR ..."
            python3 -m venv "$VENV_DIR"
            "$VENV_DIR/bin/pip" install --upgrade pip
          fi
          . "$VENV_DIR/bin/activate"

          REQS="$VENV_DIR/requirements.sel4.txt"
          if [ ! -f "$REQS" ]; then
            cat > "$REQS" <<'EOF'
            six
            future
            jinja2
            lxml
            ply
            psutil
            bs4
            pyelftools
            sh
            pexpect
            pyyaml>=5.1
            jsonschema
            pyfdt
            cmake-format==0.6.13
            guardonce
            autopep8==2.3.2
            libarchive-c
            setuptools
            EOF
          fi
          PIP_DISABLE_PIP_VERSION_CHECK=1 pip install -r "$REQS" >/dev/null

          echo "seL4 dev shell ready — $CROSS_COMPILER_PREFIX (CC=$CC)"
          echo "Switch target with:  sel4-target aarch64|arm|riscv"
        '';
      };
    });
  };
}

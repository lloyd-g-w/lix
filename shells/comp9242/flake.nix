{
  description = "seL4/AOS dev shell (pinned toolchains + host deps + auto musllibc patch)";

  # Pin to 23.11 for older binutils/gcc known to work with seL4
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

      # Cross toolchains (older versions from 23.11)
      aarch64_binutils = pkgs.pkgsCross.aarch64-embedded.buildPackages.binutils;
      aarch64_gcc = pkgs.pkgsCross.aarch64-embedded.buildPackages.gcc;

      riscv_binutils = pkgs.pkgsCross.riscv64-embedded.buildPackages.binutils;
      riscv_gcc = pkgs.pkgsCross.riscv64-embedded.buildPackages.gcc;

      arm_gcc = pkgs.gcc-arm-embedded; # arm-none-eabi-*

      py = pkgs.python3.withPackages (ps:
        with ps; [
          six
          future
          jinja2
          lxml
          ply
          psutil
          beautifulsoup4
          pyelftools
          pexpect
          pyyaml
          jsonschema
          setuptools
          autopep8
          # cmake-format and pyfdt are optional; comment in if you have them in your nixpkgs
          # cmake-format pyfdt
        ]);
    in
      pkgs.mkShell {
        packages = with pkgs; [
          # build tools / host deps
          cmake
          ninja
          ccache
          cmakeCurses
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
          gdb
          py

          # cross toolchains
          aarch64_binutils
          aarch64_gcc
          riscv_binutils
          riscv_gcc
          arm_gcc
        ];

        # Keep environment vars inside the shell (avoid leaking to parent)
        # Set default cross (AArch64); switch with `sel4-target` helper.
        shellHook = ''
          set -eu

          # ---- Pretty prompt so it's obvious you're *in* the dev shell
          if [ -n "''${PS1-}" ]; then
            export PS1="(seL4-dev) $PS1"
          fi

          # ---- Default target: aarch64
          export CROSS_COMPILER_PREFIX="aarch64-none-elf-"
          export CC="''${CROSS_COMPILER_PREFIX}gcc"
          export CXX="''${CROSS_COMPILER_PREFIX}g++"
          export LD="''${CROSS_COMPILER_PREFIX}ld"
          export AR="''${CROSS_COMPILER_PREFIX}ar"

          sel4-target () {
            case "''${1-}" in
              aarch64)
                export CROSS_COMPILER_PREFIX=aarch64-none-elf- ;;
              arm)
                export CROSS_COMPILER_PREFIX=arm-none-eabi- ;;
              riscv)
                export CROSS_COMPILER_PREFIX=riscv64-none-elf- ;;
              *)
                echo "Usage: sel4-target aarch64|arm|riscv" >&2; return 1 ;;
            esac
            export CC="''${CROSS_COMPILER_PREFIX}gcc"
            export CXX="''${CROSS_COMPILER_PREFIX}g++"
            export LD="''${CROSS_COMPILER_PREFIX}ld"
            export AR="''${CROSS_COMPILER_PREFIX}ar"
            echo "Switched to ''${CROSS_COMPILER_PREFIX} (CC=$CC)"
          }

          # ---- Auto-detect AOS repo root no matter where you run `nix develop` from
          find_aos_root () {
            for p in . .. ../.. ../../.. ../../../..; do
              if [ -e "$p/projects/musllibc/src/stdio/__stdio_exit.c" ]; then
                (cd "$p" && pwd)
                return 0
              fi
            done
            return 1
          }

          # ---- Auto-patch musllibc to avoid '__stdin_used' copy-reloc link failure
          # Idempotent: only applies once and only if needed.
          if AOS_ROOT="$(find_aos_root)"; then
            FILE="$AOS_ROOT/projects/musllibc/src/stdio/__stdio_exit.c"
            # Only patch if the symbol is still the old declaration
            if grep -Eq '^[[:space:]]*volatile[[:space:]]+int[[:space:]]+__stdin_used[[:space:]]*;[[:space:]]*$' "$FILE"; then
              echo "[seL4-dev] Patching musllibc (__stdin_used visibility -> hidden) in: $FILE"
              cp "$FILE" "$FILE.bak"
              sed -i \
                's/^[[:space:]]*volatile[[:space:]]\+int[[:space:]]\+__stdin_used[[:space:]]*;$/__attribute__((visibility("hidden"))) volatile int __stdin_used = 0;/' \
                "$FILE"
            fi
          fi

          # Helpful reminder
          echo "seL4 dev shell ready — CROSS=''${CROSS_COMPILER_PREFIX} (CC=$CC)"
          echo "Switch target with:  sel4-target aarch64|arm|riscv"
        '';
      });
  };
}

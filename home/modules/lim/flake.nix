{
  description = "Lim--A Neovim configuration";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    flake-parts,
    ...
  }: let
    getNeovimDeps = pkgs:
      with pkgs; [
        lazygit
        tree-sitter
        texpresso
        tectonic
        ripgrep

        nixd
        texlab
        lua-language-server
        svelte-language-server
        jdt-language-server
        typescript-language-server
        vim-language-server
        basedpyright
        csharp-ls
        cmake-language-server
        tailwindcss-language-server
        tinymist
        rust-analyzer
        zls
        qt6Packages.qtdeclarative

        llvmPackages.clang-tools

        tex-fmt
        rustfmt
        markdownlint-cli
        alejandra
        yq-go
        black
        jq
        stylua
        nodePackages.prettier
        astyle

        vscode-extensions.ms-vscode.cpptools
        gdb
      ];
  in
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = ["x86_64-linux" "aarch64-linux" "aarch64-darwin" "x86_64-darwin"];

      perSystem = {system, ...}: let
        pkgs = import nixpkgs {
          inherit system;
          config = {
            allowUnfree = true;
            permittedInsecurePackages = ["libsoup-2.74.3"];
          };
        };

        deps = getNeovimDeps pkgs;

        # Source directory
        neovim-config-src = ./.;

        # Packaged config (store path)
        neovim-config-pkg = pkgs.stdenvNoCC.mkDerivation {
          pname = "lim-nvim-config";
          version = "0.1.0";
          src = pkgs.lib.cleanSource neovim-config-src;
          dontBuild = true;
          installPhase = ''
            mkdir -p $out
            cp -R . $out/
          '';
        };

        neovim-init-pkg = "${neovim-config-pkg}/init.lua";

        cppToolsPath = "${pkgs.vscode-extensions.ms-vscode.cpptools}/share/vscode/extensions/ms-vscode.cpptools";

        limPkg = pkgs.writeShellApplication {
          name = "lim";
          runtimeInputs = [pkgs.neovim] ++ deps;
          text = ''
            export OPEN_DEBUG_AD7="${cppToolsPath}/debugAdapters/bin/OpenDebugAD7"
            exec nvim --cmd "set rtp^=${neovim-config-pkg}" -u ${neovim-init-pkg} "$@"
          '';
        };
      in {
        packages = {
          neovim-config = neovim-config-pkg;
          lim = limPkg;
          default = limPkg;
        };

        apps.default = {
          type = "app";
          program = "${limPkg}/bin/lim";
        };

        devShells.default = pkgs.mkShell {
          name = "neovim-dev-shell";
          packages = [pkgs.neovim] ++ deps;

          shellHook = ''
            export OPEN_DEBUG_AD7="${cppToolsPath}/debugAdapters/bin/OpenDebugAD7"
            alias nvim='nvim --cmd "set rtp^=${neovim-config-src}" -u ${neovim-config-src}/init.lua'
            echo "Neovim dev shell activated."
          '';
        };
      };

      flake = {
        homeManagerModules.default = {
          config,
          lib,
          pkgs,
          ...
        }: let
          cfg = config.programs.lim;
          system = pkgs.stdenv.hostPlatform.system;
        in {
          options.programs.lim = {
            enable = lib.mkEnableOption "Lim setup";

            # When set, we symlink ~/.config/nvim -> devPath (out-of-store),
            # so edits apply immediately without rebuilding.
            devPath = lib.mkOption {
              type = with lib.types; nullOr str;
              default = null;
              example = "/home/you/src/lim";
              description = ''
                Absolute path to your Lim repo to symlink into ~/.config/nvim.
                If null, Home Manager uses the packaged config from the flake (store path).
              '';
            };
          };

          config = lib.mkIf cfg.enable {
            nixpkgs.config = {
              allowUnfree = true;
              permittedInsecurePackages = ["libsoup-2.74.3"];
            };

            # Put lim + its deps in your profile
            home.packages =
              (getNeovimDeps pkgs)
              ++ [self.packages.${system}.lim];

            programs.neovim.enable = true;

            home.file.".config/nvim".source =
              if cfg.devPath != null
              then config.lib.file.mkOutOfStoreSymlink cfg.devPath
              else self.packages.${system}.neovim-config;

            home.sessionVariables.OPEN_DEBUG_AD7 = "${pkgs.vscode-extensions.ms-vscode.cpptools}/share/vscode/extensions/ms-vscode.cpptools/debugAdapters/bin/OpenDebugAD7";
          };
        };
      };
    };
}

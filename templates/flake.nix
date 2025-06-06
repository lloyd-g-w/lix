{
  description = "Generate templates for several prog langs";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = {
    self,
    nixpkgs,
    ...
  }: let
    supportedSystems = ["x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin"];
    forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
  in {
    packages = forAllSystems (system: let
      pkgs = import nixpkgs {inherit system;};
    in {
      comp4128 = pkgs.stdenv.mkDerivation {
        pname = "comp4128-template-generator";
        version = "0.1.0";

        src = ./.;

        buildInputs = [pkgs.bash];

        installPhase = ''
          mkdir -p $out/bin
          mkdir -p $out/share

          # 2. Paths inside the script must be relative to the root, so 'comp4128/...' is correct.
          cp comp4128/comp4128.cpp $out/share/
          cp comp4128/comp4128.sh $out/bin/

          # Make the script executable and rename it for a cleaner command
          chmod +x $out/bin/comp4128.sh
          mv $out/bin/comp4128.sh $out/bin/comp4128

          # Substitute the placeholder path in the final script
          substituteInPlace $out/bin/comp4128 \
            --replace "@template_path@" "$out/share/comp4128.cpp"
        '';
      };

      default = self.packages.${system}.comp4128;
    });

    apps = forAllSystems (system: {
      comp4128 = {
        type = "app";
        # Update the program path to reflect the rename
        program = "${self.packages.${system}.comp4128}/bin/comp4128";
      };
      default = self.apps.${system}.comp4128;
    });
  };
}

{
  description = "Lix--A NixOS and Home Manager Configuration";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";

    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    elephant.url = "github:abenz1267/elephant";

    walker = {
      url = "github:abenz1267/walker";
      inputs.elephant.follows = "elephant";
    };

    lim = {
      url = "github:lloyd-g-w/lim";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    latus = {
      url = "github:lloyd-g-w/latus";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ {flake-parts, ...}:
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = ["x86_64-linux" "aarch64-linux" "aarch64-darwin" "x86_64-darwin"];

      imports =
        [
          inputs.home-manager.flakeModules.home-manager
          ./options # This exposes the avaliable lix options
          ./nixos
          ./home
          ./overlays
          ./pkgs
          ./shells
          ./templates
        ]
        ++ (
          let
            # This is where you define the lix options you want
            # this needs to be bootstrapped intially (e.g. LIX_DIR="DIR" sudo home-manager rebuild switch ...)
            # but then is set by home manager and is defined in your config
            CONFIG_DIR = builtins.getEnv "LIX_DIR" + "/config.nix";
          in
            if builtins.pathExists CONFIG_DIR
            then [(/. + CONFIG_DIR)]
            else []
        );

      lix.home.sharedModules = [
        inputs.walker.homeManagerModules.default
        inputs.lim.homeManagerModules.default
      ];

      lix.os.sharedModules = [
      ];
    };
}

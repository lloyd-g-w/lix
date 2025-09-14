{
  inputs,
  pkgs,
  ...
}: {
  nixpkgs.overlays = [(import ./overlays)];

  # Set nix registry
  home.file.".config/nix/registry.json".text = let
    flakeInfo = {
      comp3891 = {
        type = "path";
        path = "${inputs.self}/shells/comp3891";
      };
      comp9242 = {
        type = "path";
        path = "${inputs.self}/shells/comp9242";
      };
      progtemp = {
        type = "path";
        path = "${inputs.self}/templates";
      };
    };

    registryEntries = builtins.map (
      alias: let
        attrs = builtins.getAttr alias flakeInfo;
      in {
        from = {
          type = "indirect";
          id = alias;
        };
        to = {
          type = attrs.type;
          path = attrs.path;
        };
      }
    ) (builtins.attrNames flakeInfo);

    registryJson = builtins.toJSON {
      version = 2;
      flakes = registryEntries;
    };
  in
    registryJson;
}

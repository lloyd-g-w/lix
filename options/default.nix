{lib, ...}: let
  inherit (lib) mkOption types;
in {
  options = {
    lix = {
      home = {
        sharedModules = mkOption {
          type = types.listOf types.deferredModule;
          default = [];
          description = "Modules to be included in all Home Manager configurations.";
        };

        niri = {
          monitors = mkOption {
            type = types.listOf (types.submodule {
              options = {
                name = mkOption {
                  type = types.str;
                  description = "Monitor name (e.g. HDMI-A-1, DP-1).";
                };

                scale = mkOption {
                  type = types.float;
                  default = 1.0;
                  description = "Scaling factor for this monitor.";
                };

                pos = mkOption {
                  type = types.nullOr (types.submodule {
                    options = {
                      x = mkOption {
                        type = types.int;
                        description = "X position of this monitor.";
                      };
                      y = mkOption {
                        type = types.int;
                        description = "Y position of this monitor.";
                      };
                    };
                  });
                  default = null;
                  description = "Optional position; when null, no position line is emitted.";
                };
              };
            });

            default = [];
            description = "A list of monitor configurations for niri.";
          };
        };
      };

      os = {
        sharedModules = mkOption {
          type = types.listOf types.deferredModule;
          default = [];
          description = "Modules to be included in all NixOS configurations.";
        };
      };

      compositor = mkOption {
        type = types.enum ["niri"];
        default = "niri";
        description = "The compositor for lix (currently only niri).";
      };

      host = mkOption {
        type = types.str;
        default = "desktop";
        description = "The lix hostname of the system.";
      };

      user = mkOption {
        type = types.str;
        default = "lloyd";
        description = "The lix user of the system.";
      };

      dir = mkOption {
        type = types.str;
        default = "$HOME/projects/lix";
        description = "The directory of the main lix config.";
      };
    };
  };
}

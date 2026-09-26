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

        monitors = mkOption {
          type = types.listOf (types.submodule {
            options = {
              name = mkOption {
                type = types.nullOr types.str;
                default = null;
                description = "Connector name to match (e.g. HDMI-A-1, DP-1). Use this or make/model/serial.";
              };

              make = mkOption {
                type = types.nullOr types.str;
                default = null;
                description = "Monitor manufacturer to match (as reported by wlr-randr / niri msg outputs).";
              };

              model = mkOption {
                type = types.nullOr types.str;
                default = null;
                description = "Monitor model to match.";
              };

              serial = mkOption {
                type = types.nullOr types.str;
                default = null;
                description = "Monitor serial number to match.";
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
                description = "Optional position; when null, the compositor picks one.";
              };

              mode = mkOption {
                type = types.nullOr (types.submodule {
                  options = {
                    width = mkOption {
                      type = types.int;
                      description = "Mode width in pixels.";
                    };
                    height = mkOption {
                      type = types.int;
                      description = "Mode height in pixels.";
                    };
                    refresh = mkOption {
                      type = types.nullOr types.float;
                      default = null;
                      description = "Optional refresh rate in Hz.";
                    };
                  };
                });
                default = null;
                description = "Optional mode; when null, the compositor picks the preferred mode.";
              };

              vrr = mkOption {
                type = types.bool;
                default = false;
                description = "Enable variable refresh rate on this monitor.";
              };

              niri.extraConfig = mkOption {
                type = types.lines;
                default = "";
                description = "Extra KDL lines appended inside this monitor's niri output block.";
              };

              mango.extraRule = mkOption {
                type = types.str;
                default = "";
                description = "Extra comma-separated parameters appended to this monitor's mango monitorrule (e.g. \"rr:1,hdr:1\").";
              };
            };
          });

          default = [];
          description = "Monitor configurations, translated to every enabled compositor.";
        };
      };

      os = {
        sharedModules = mkOption {
          type = types.listOf types.deferredModule;
          default = [];
          description = "Modules to be included in all NixOS configurations.";
        };
      };

      compositors = mkOption {
        type = types.nonEmptyListOf (types.enum ["niri" "mango"]);
        default = ["niri"];
        description = "The compositors to enable for lix. The first one is the default login session.";
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

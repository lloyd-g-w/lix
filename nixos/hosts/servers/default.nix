# Every folder here with a hardware-configuration.nix is a server, e.g.
# ./optiplex -> host "server-optiplex". A folder can also have a default.nix
# for per-machine overrides (bootloader, network interface, ...).
#
# Returns { "server-<folder>" = <NixOS module>; ... }
let
  isServer = name: type:
    type == "directory" && builtins.pathExists (./. + "/${name}/hardware-configuration.nix");
  entries = builtins.readDir ./.;
  names = builtins.filter (name: isServer name entries.${name}) (builtins.attrNames entries);
in
  builtins.listToAttrs (map (name: {
      name = "server-${name}";
      value = import ./common.nix name;
    })
    names)

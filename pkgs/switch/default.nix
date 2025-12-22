{
  pkgs,
  lix,
  ...
}: let
  host = lix.host;
  user = lix.user;
  dir = lix.dir;
in {
  packages = {
    ns = pkgs.writeShellScriptBin "ns" ''
      nh os switch ${dir}#${host}
    '';

    hs = pkgs.writeShellScriptBin "hs" ''
      nh home switch ${dir}#${user}@${host}
    '';
  };
}

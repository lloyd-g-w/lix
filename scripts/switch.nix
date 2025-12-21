{
  config,
  pkgs,
  ...
}: let
  host = config.lix.host;
  user = config.lix.user;
  dir = config.lix.dir;
in {
  home.packages = [
    (pkgs.writeShellScriptBin "ns" ''
      nh os switch
      # sudo nixos-rebuild switch --flake ${dir}#${host}
    '')

    (pkgs.writeShellScriptBin "hs" ''
      nh home switch
      # home-manager switch --flake ${dir}#${user}@${host}
    '')
  ];
}

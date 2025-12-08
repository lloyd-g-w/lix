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
      #!/usr/bin/env bash
      sudo nixos-rebuild switch --flake ${dir}#${host}
    '')

    (pkgs.writeShellScriptBin "hs" ''
      #!/usr/bin/env bash
      home-manager switch --flake ${dir}#${user}@${host}
    '')
  ];
}

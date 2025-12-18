{pkgs, ...}: {
  home.packages = [
    (pkgs.writeShellScriptBin "dev" (builtins.readFile ./dev.sh))
  ];
}

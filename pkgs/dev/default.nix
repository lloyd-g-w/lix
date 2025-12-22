{pkgs, ...}: {
  packages.dev = pkgs.writeShellScriptBin "dev" (builtins.readFile ./dev.sh);
}

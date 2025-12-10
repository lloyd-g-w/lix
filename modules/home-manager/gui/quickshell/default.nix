{
  config,
  lib,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    quickshell
  ];

  home.file.".config/quickshell/shell.qml".source = ./shell.qml;
}

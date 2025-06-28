{pkgs}:
pkgs.wrapProgram pkgs.discord [
  "--prefix"
  "XDG_DESKTOP_PORTAL"
  "xdg-desktop-portal-hyprland"
  "--prefix"
  "OZONE_PLATFORM"
  "wayland"
]

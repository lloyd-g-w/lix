{pkgs, ...}: {
  home.packages = with pkgs; [
    xfce.thunar
    xfce.tumbler # core thumbnail daemon
    xfce.thunar-media-tags-plugin
    xfce.thunar-archive-plugin
    kdePackages.ark
    ffmpegthumbnailer # video thumbnailer
  ];
}

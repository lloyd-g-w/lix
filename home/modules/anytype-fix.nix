{pkgs, ...}: let
  anytype-fix = pkgs.anytype.overrideAttrs (old: {
    postFixup =
      (old.postFixup or "")
      + ''
        wrapProgram $out/bin/anytype \
          --set ORIGINAL_XDG_CURRENT_DESKTOP GNOME \
          --set NIXOS_OZONE_WL 0 \
          --set ELECTRON_OZONE_PLATFORM_HINT x11
      '';
  });
in {
  home.packages = [anytype-fix];

  home.file.".local/share/applications/anytype.desktop" = {
    force = true;
    text = ''
      [Desktop Entry]
      Categories=Utility;Office;Calendar;ProjectManagement
      Comment=P2P note-taking tool
      Exec=${anytype-fix}/bin/anytype %u
      Icon=anytype
      MimeType=x-scheme-handler/anytype
      Name=Anytype
      StartupWMClass=anytype
      Type=Application
      Version=1.5
    '';
  };
}

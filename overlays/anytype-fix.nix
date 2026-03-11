final: prev: {
  anytype-fix = prev.anytype.overrideAttrs (old: {
    postFixup =
      (old.postFixup or "")
      + ''
        wrapProgram $out/bin/anytype \
          --set ORIGINAL_XDG_CURRENT_DESKTOP GNOME
      '';
  });
}

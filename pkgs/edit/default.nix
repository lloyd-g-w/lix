{pkgs, ...}: {
  packages.edit = let
    edit = pkgs.writeShellScriptBin "edit" (builtins.readFile ./edit.sh);
  in
    pkgs.symlinkJoin {
      name = "edit";
      paths = [edit];
      postBuild = "ln -s edit $out/bin/e";
      meta.mainProgram = "edit";
    };
}

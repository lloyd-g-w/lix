{pkgs, ...}: {
  devShells.leet = pkgs.mkShell {
    packages = with pkgs; [
      gcc
      clang
      gdb
      git
    ];

    shellHook = ''
      exec zsh
      export CC=gcc
      export CXX=g++
      echo "CXX=$CXX"
    '';
  };
}

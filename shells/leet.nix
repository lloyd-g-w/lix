{pkgs, ...}: {
  devShells.leet = pkgs.mkShell {
    packages = with pkgs; [
      gcc
      clang
      gdb
      git
      nixfmt-rfc-style
    ];

    shellHook = ''
      export CC=gcc
      export CXX=g++
      echo "CXX=$CXX"
    '';
  };
}

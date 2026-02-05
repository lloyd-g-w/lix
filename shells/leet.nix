{pkgs, ...}: {
  devShells.leet = pkgs.mkShell {
    packages = with pkgs; [
      gcc
      clang
      clang-tools
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

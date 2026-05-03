{pkgs, ...}: {
  devShells.leet = pkgs.mkShell {
    packages = with pkgs; [
      gcc
      clang
      gdb
      git
      zsh
    ];

    shellHook = ''
      export CC=gcc
      export CXX=g++
      echo "CXX=$CXX"

      # exec zsh
      exec dev leetcode.nvim # Open leetcode plugin in nvim with custom dev program. See pkgs/dev
    '';
  };
}

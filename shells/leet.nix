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
      edit leetcode.nvim # Open leetcode plugin in nvim with custom edit program. See pkgs/edit
    '';
  };
}

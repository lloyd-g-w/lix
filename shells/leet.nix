{pkgs, ...}: {
  devShells.leet = pkgs.mkShell {
    packages = with pkgs; [
      stdenv.cc # <- provides libstdc++ headers/libs
      clang
      clang-tools
      cmake
      gnumake
      pkg-config
      gdb
      lldb
    ];
  };
}

{pkgs', ...}: {
  devShells.leet = pkgs'.mkShell {
    packages = with pkgs'; [
      clang
      llvmPackages.lld
      cmake
      gnumake
      pkg-config
    ];

    shellHook = ''
      echo "LeetCode C++ shell: clang++ + clangd + (gdb/lldb/valgrind)"
      echo "Tip: compile with: clang++ -std=c++20 -O2 -Wall -Wextra -pedantic main.cpp -o main"
    '';
  };
}

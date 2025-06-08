#!/usr/bin/env bash

template_file="@template_path@"
make_file="@make_path@"
clangd_file="@clangd_file@"
clang_format_file="@clang_format_file@"
destination_file=""

if [ "$#" -eq 0 ]; then
  destination_file="main.cpp"
else
  destination_file="$1"
  case "$destination_file" in
    *.cpp) ;;
    *) destination_file="${destination_file}.cpp" ;;
  esac
fi


if [ ! -f "$template_file" ]; then
  echo "Error: Template file not found at '$template_file'"
  exit 1
fi

# Use `cat` to redirect the content, creating a new, writable file.
cat "$template_file" > "$destination_file"
cat "$make_file" > "Makefile"
cat "$clangd_file" > ".clangd"
cat "$clang_format_file" > ".clang-format"

echo "Constructed COMP4128 file: $destination_file"


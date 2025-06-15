#!/usr/bin/env bash

template_file="@template_path@"
make_file="@make_path@"
clangd_file="@clangd_file@"
clang_format_file="@clang_format_file@"
diary_file="@diary_file@"

copy_template=true
copy_make=true
copy_diary=true
copy_clangd=false
copy_clang_format=false

destination_file="main.cpp"

if [ "$#" -ge 1 ]; then
  case "$1" in
    setup)
      copy_template=false
      copy_make=false
      copy_clangd=true
      copy_clang_format=true
      ;;
    all)
      copy_clangd=true
      copy_clang_format=true
      copy_make=true
      copy_template=true
      if [ "$#" -ge 2 ]; then
        destination_file="$2"
        case "$destination_file" in
          *.cpp) ;;
          *) destination_file="${destination_file}.cpp" ;;
        esac
      fi
      ;;
    *)
      destination_file="$1"
      case "$destination_file" in
        *.cpp) ;;
        *) destination_file="${destination_file}.cpp" ;;
      esac
      ;;
  esac
fi

if $copy_template; then
  if [ ! -f "$template_file" ]; then
    echo "Error: Template file not found at '$template_file'"
    exit 1
  fi
  cat "$template_file" > "$destination_file"
  echo "Created: $destination_file"
fi


if $copy_diary; then
  mkdir "diary"
  cat "$diary_file" > "diary/diary.tex"
  echo "Created: diary/diary.tex"
fi

if $copy_make; then
  cat "$make_file" > "Makefile"
  echo "Created: Makefile"
fi

if $copy_clangd; then
  cat "$clangd_file" > ".clangd"
  echo "Created: .clangd"
fi

if $copy_clang_format; then
  cat "$clang_format_file" > ".clang-format"
  echo "Created: .clang-format"
fi

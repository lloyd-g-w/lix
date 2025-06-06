#!/usr/bin/env bash
template_file="@template_path@"
destination_file=""

if [ -z "$1" ]; then
  destination_file="main.cpp"
else
  destination_file="$1"
  # If the user didn’t supply a ".cpp" suffix, append it
  case "$destination_file" in
    *.cpp) ;;
    *) destination_file="${destination_file}.cpp" ;;
  esac
fi


if [ ! -f "$template_file" ]; then
  echo "Error: Template file not found at '$template_file'"
  exit 1
fi

# --- Copy the Template to the Destination File ---
cp "$template_file" "$destination_file"

echo "Constructed the COMP4128 template file."

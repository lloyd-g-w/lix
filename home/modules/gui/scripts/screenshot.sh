#!/usr/bin/env bash
mkdir -p "$HOME/Pictures/Screenshots" && grim -g "$(slurp)" - | tee "$HOME/Pictures/Screenshots/screenshot_$(date +%s).png" | wl-copy

#!/usr/bin/env bash

DEV="*kbd*"
CUR=$(brightnessctl --device="$DEV" get)
MAX=$(brightnessctl --device="$DEV" max)

# Define your cycle levels (customizable)
LEVELS=(0 1 2 $MAX)

# Find next level
for i in "${!LEVELS[@]}"; do
    if [[ ${LEVELS[$i]} -eq $CUR ]]; then
        NEXT=${LEVELS[$(( (i + 1) % ${#LEVELS[@]} ))]}
        brightnessctl --device="$DEV" set "$NEXT"
        exit 0
    fi
done

# fallback if current not in levels
brightnessctl --device="$DEV" set "${LEVELS[0]}"


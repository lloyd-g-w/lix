#!/usr/bin/env bash
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
sudo "$SCRIPT_DIR/rebuild-os.sh" && "$SCRIPT_DIR/rebuild-home.sh"

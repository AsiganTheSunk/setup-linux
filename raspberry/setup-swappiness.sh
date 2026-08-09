#!/usr/bin/env bash

# Abort on error, unset variables, or failed pipelines
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC="$SCRIPT_DIR/99-swappiness.conf"
DEST="/etc/sysctl.d/99-swappiness.conf"

if [[ ! -f "$SRC" ]]; then
  echo "Missing source config: $SRC"
  exit 1
fi

sudo install -o root -g root -m 644 "$SRC" "$DEST"
sudo sysctl --system >/dev/null

echo "[~]: Installed $DEST (swappiness=$(sysctl -n vm.swappiness))"

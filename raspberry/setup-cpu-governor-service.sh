#!/usr/bin/env bash

# Abort on error, unset variables, or failed pipelines
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC="$SCRIPT_DIR/cpu-governor.service"
DEST="/etc/systemd/system/cpu-governor.service"

if [[ ! -f "$SRC" ]]; then
  echo "Missing source unit: $SRC"
  exit 1
fi

sudo install -o root -g root -m 644 "$SRC" "$DEST"
sudo systemctl daemon-reload
sudo systemctl enable --now cpu-governor.service

echo "[~]: Installed $DEST (governor=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor 2>/dev/null || echo n/a))"

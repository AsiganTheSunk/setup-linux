#!/usr/bin/env bash

# Abort on error, unset variables, or failed pipelines
set -euo pipefail

DEST="/etc/systemd/system/cpu-governor.service"

if [[ ! -f "$DEST" ]]; then
  echo "Missing unit: $DEST"
  exit 1
fi

sudo systemctl disable --now cpu-governor.service
sudo rm -f "$DEST"
sudo systemctl daemon-reload

echo "[~]: Removed $DEST"

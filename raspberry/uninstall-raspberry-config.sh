#!/usr/bin/env bash

# Abort on error, unset variables, or failed pipelines
set -euo pipefail

DEST="/boot/firmware/config.txt"
BACKUP="${DEST}.bak"

if [[ ! -f "$BACKUP" ]]; then
  echo "Missing backup: $BACKUP"
  exit 1
fi

sudo rm -f "$DEST"
sudo mv "$BACKUP" "$DEST"

echo "[~]: Restored $DEST from backup"

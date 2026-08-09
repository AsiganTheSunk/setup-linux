#!/usr/bin/env bash

# Abort on error, unset variables, or failed pipelines
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC="$SCRIPT_DIR/config.txt"
DEST="/boot/firmware/config.txt"
BACKUP="${DEST}.bak"

if [[ ! -f "$SRC" ]]; then
  echo "Missing source config: $SRC"
  exit 1
fi

if [[ ! -f "$DEST" ]]; then
  echo "Missing destination: $DEST"
  exit 1
fi

OWNER=$(stat -c '%U' "$DEST")
GROUP=$(stat -c '%G' "$DEST")
MODE=$(stat -c '%a' "$DEST")

sudo install -o "$OWNER" -g "$GROUP" -m "$MODE" "$DEST" "$BACKUP"
sudo install -o "$OWNER" -g "$GROUP" -m "$MODE" "$SRC" "$DEST"

echo "[~]: Installed $DEST (backup: $BACKUP)"

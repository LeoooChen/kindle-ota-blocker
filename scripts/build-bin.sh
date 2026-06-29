#!/bin/sh

set -eu

ROOT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
DIST_DIR="$ROOT_DIR/dist"
STAGE_DIR="$DIST_DIR/ota-root"
OUT_BIN="$DIST_DIR/Update_kindle_ota_blocker_universal.bin"

rm -rf "$STAGE_DIR" "$OUT_BIN"
mkdir -p "$STAGE_DIR/payload"
cp -R "$ROOT_DIR/kindle-ota-blocker" "$STAGE_DIR/payload/"
cp "$ROOT_DIR/package/install.sh" "$STAGE_DIR/install.sh"
chmod 755 "$STAGE_DIR/install.sh"

if command -v kindletool >/dev/null 2>&1; then
  kindletool create ota2 -d kindle4 -d kindle5 -s min -t max -O -C "$STAGE_DIR" "$OUT_BIN" -x PackagedBy=kindle-ota-blocker
  printf 'Built %s\n' "$OUT_BIN"
else
  printf 'kindletool not found. Staged OTA root at %s\n' "$STAGE_DIR"
  printf 'Install kindletool, then rerun to emit %s\n' "$OUT_BIN"
  exit 1
fi

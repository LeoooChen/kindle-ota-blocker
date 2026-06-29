#!/bin/sh

set -eu

TARGET_DIR="/mnt/us/extensions/kindle-ota-blocker"
SOURCE_DIR="./payload/kindle-ota-blocker"

mkdir -p "$TARGET_DIR/bin"
cp -f "$SOURCE_DIR/README.md" /mnt/us/kindle-ota-blocker.README.md 2>/dev/null || true
cp -f "$SOURCE_DIR/config.xml" "$TARGET_DIR/config.xml"
cp -f "$SOURCE_DIR/menu.json" "$TARGET_DIR/menu.json"
cp -f "$SOURCE_DIR/bin/"*.sh "$TARGET_DIR/bin/"
chmod 755 "$TARGET_DIR/bin/"*.sh

exit 0

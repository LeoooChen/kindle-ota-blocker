#!/bin/sh

DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
. "$DIR/lib.sh"

cmd="${1:-check}"

case "$cmd" in
  check)
    quick_check
    ;;
  recheck)
    maybe_recheck
    ;;
  block)
    block_ota
    ;;
  restore)
    restore_ota
    ;;
  rescue)
    rescue_mode
    ;;
  *)
    printf 'Usage: %s {check|recheck|block|restore|rescue}\n' "$0"
    exit 1
    ;;
esac

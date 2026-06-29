#!/bin/sh

EXT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
STATE_DIR="${EXT_DIR}/.state"
STATE_FILE="${STATE_DIR}/ota-blocker.state"
LOG_FILE="/mnt/us/ota-blocker.log"
PREFER_ROOTS="/mnt/us /mnt/ub /mnt/mmc"
PREFERRED_MARKER="update.bin.tmp.partial"
AUTO_RECHECK_FLAG="${STATE_DIR}/auto-recheck.enabled"

log() {
  printf '%s %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$*" >> "$LOG_FILE"
}

ensure_state_dir() {
  [ -d "$STATE_DIR" ] || mkdir -p "$STATE_DIR"
}

read_state() {
  if [ -f "$STATE_FILE" ]; then
    cat "$STATE_FILE"
  fi
}

write_state() {
  ensure_state_dir
  : > "$STATE_FILE"
  printf '%s\n' "$1" >> "$STATE_FILE"
}

read_persisted_state() {
  if [ -f "$STATE_FILE" ]; then
    cat "$STATE_FILE"
  fi
}

set_auto_recheck() {
  ensure_state_dir
  case "$1" in
    on)
      : > "$AUTO_RECHECK_FLAG"
      ;;
    off)
      rm -f "$AUTO_RECHECK_FLAG"
      ;;
  esac
}

auto_recheck_enabled() {
  [ -f "$AUTO_RECHECK_FLAG" ]
}

device_root_candidates() {
  printf '%s\n' $PREFER_ROOTS
}

find_device_root() {
  for d in $(device_root_candidates); do
    if [ -d "$d" ]; then
      printf '%s\n' "$d"
      return 0
    fi
  done
  return 1
}

ota_marker_path() {
  root="$(find_device_root 2>/dev/null || true)"
  if [ -n "$root" ]; then
    printf '%s\n' "$root/$PREFERRED_MARKER"
    return 0
  fi
  printf '%s\n' "/mnt/us/$PREFERRED_MARKER"
}

is_blocked() {
  marker="$(ota_marker_path)"
  [ -d "$marker" ] || [ -f "$marker" ]
}

current_status() {
  if is_blocked; then
    printf '%s\n' "blocked"
  else
    printf '%s\n' "unblocked"
  fi
}

firmware_series() {
  if [ -f /etc/prettyversion.txt ]; then
    ver="$(tr -d '\r' < /etc/prettyversion.txt | head -n 1)"
    case "$ver" in
      5.10*|5.9*|5.8*|5.7*|5.6*|5.5*|5.4*|5.3*|5.2*|5.1*)
        printf '%s\n' "legacy"
        return 0
        ;;
      5.11*|5.12*|5.13*|5.14*|5.15*|5.16*|5.17*|5.18*|5.19*)
        printf '%s\n' "modern"
        return 0
        ;;
    esac
  fi
  printf '%s\n' "unknown"
}

strategy_name() {
  case "$(firmware_series)" in
    legacy) printf '%s\n' "marker-dir" ;;
    modern) printf '%s\n' "marker-dir" ;;
    *) printf '%s\n' "safe-check" ;;
  esac
}

quick_check() {
  status="$(current_status)"
  fw="$(firmware_series)"
  strat="$(strategy_name)"
  persist="$(read_persisted_state)"
  recheck="off"
  if auto_recheck_enabled; then
    recheck="on"
  fi
  log "status=${status} firmware=${fw} strategy=${strat} auto_recheck=${recheck}"
  printf 'Status: %s\n' "$status"
  printf 'Firmware: %s\n' "$fw"
  printf 'Strategy: %s\n' "$strat"
  printf 'Auto recheck: %s\n' "$recheck"
  [ -n "$persist" ] && printf 'Persisted: %s\n' "$persist"
}

block_ota() {
  marker="$(ota_marker_path)"
  marker_dir="$(dirname "$marker")"

  if [ ! -d "$marker_dir" ]; then
    printf 'No Kindle storage found.\n'
    return 1
  fi

  if [ -e "$marker" ] && [ ! -d "$marker" ]; then
    rm -f "$marker"
  fi

  if [ ! -d "$marker" ]; then
    mkdir -p "$marker" || return 1
  fi

  chmod a=r "$marker" 2>/dev/null || true
  write_state "blocked"
  set_auto_recheck on
  log "blocked via ${marker}"
  printf 'OTA block applied.\n'
}

restore_ota() {
  marker="$(ota_marker_path)"
  if [ -d "$marker" ]; then
    rmdir "$marker" 2>/dev/null || rm -rf "$marker"
  elif [ -f "$marker" ]; then
    rm -f "$marker"
  fi

  write_state "unblocked"
  set_auto_recheck off
  log "restored"
  printf 'OTA restored.\n'
}

rescue_mode() {
  restore_ota
  printf 'Rescue mode completed.\n'
}

maybe_recheck() {
  if auto_recheck_enabled; then
    quick_check
  else
    printf 'Auto recheck disabled.\n'
  fi
}

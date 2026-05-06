#!/bin/bash

# omarchy:summary=Enable, disable, toggle, or recover the internal laptop display
# omarchy:args=<on|off|toggle|recover>
# based on omarchy-hyprland-monitor-internal but with adjusted monitor detection and safety checks
# original: ~/.local/share/omarchy/bin/omarchy-hyprland-monitor-internal

TOGGLE="internal-monitor-disable"
TOGGLE_FLAG="$HOME/.local/state/omarchy/toggles/hypr/$TOGGLE.conf"
MIRROR_TOGGLE="internal-monitor-mirror"

# Optional override: export INTERNAL_MONITOR=DSI-1
resolve_internal_monitor() {
  if [[ -n "${INTERNAL_MONITOR:-}" ]]; then
    hyprctl monitors -j | jq -r --arg internal "$INTERNAL_MONITOR" '.[] | select(.name == $internal) | .name' | head -n 1
    return 0
  fi

  hyprctl monitors -j | jq -r '.[] | select(.name | test("^(eDP|DSI|LVDS)")) | .name' | head -n 1
}

active_monitor_count() {
  hyprctl monitors -j | jq -r '[.[] | select(.disabled | not)] | length'
}

has_non_internal_active_monitor() {
  hyprctl monitors -j | jq -e --arg internal "$INTERNAL" '[.[] | select(.disabled | not) | select(.name != $internal)] | length > 0' >/dev/null
}

INTERNAL="$(resolve_internal_monitor)"

enable() {
  if omarchy-hyprland-toggle-enabled "$TOGGLE"; then
    omarchy-hyprland-toggle --disabled-notification "󰍹    Laptop display enabled" "$TOGGLE"
  fi
}

disable() {
  if [[ -z "$INTERNAL" ]]; then
    notify-send -u low "No internal monitor detected"
    exit 1
  fi

  if [[ "$(active_monitor_count)" -le 1 ]]; then
    notify-send -u low "Can't disable only active display"
    exit 1
  fi

  if ! has_non_internal_active_monitor; then
    notify-send -u low "No active external display"
    exit 1
  fi

  if omarchy-hyprland-toggle-disabled "$TOGGLE" && omarchy-hyprland-toggle-disabled "$MIRROR_TOGGLE"; then
    echo "monitor=$INTERNAL,disable" >"$TOGGLE_FLAG"
    notify-send -u low "Laptop display disabled"
    hyprctl reload
  fi
}

recover() {
  if omarchy-hyprland-toggle-enabled "$TOGGLE" && ! has_non_internal_active_monitor; then
    omarchy-hyprland-toggle "$TOGGLE"
  fi
}

case "$1" in
  on) enable ;;
  off) disable ;;
  toggle) if omarchy-hyprland-toggle-enabled "$TOGGLE"; then enable; else disable; fi ;;
  recover) recover ;;
  *)
    echo "Usage: $(basename "$0") {on|off|toggle|recover}" >&2
    exit 1
    ;;
esac

#!/bin/bash

# User override for internal display mirroring without modifying Omarchy core files.
# Supports INTERNAL_MONITOR and MIRROR_EXTERNAL_MONITOR environment overrides.

set -euo pipefail

TOGGLE="internal-monitor-mirror"
TOGGLE_FLAG="$HOME/.local/state/omarchy/toggles/hypr/$TOGGLE.conf"
DISABLE_TOGGLE="internal-monitor-disable"

resolve_internal_monitor() {
  if [[ -n "${INTERNAL_MONITOR:-}" ]]; then
    hyprctl monitors -j | jq -r --arg internal "$INTERNAL_MONITOR" '.[] | select(.name == $internal) | .name' | head -n 1
    return 0
  fi

  hyprctl monitors -j | jq -r '.[] | select(.name | test("^(eDP|DSI|LVDS)")) | .name' | head -n 1
}

resolve_external_monitor() {
  if [[ -n "${MIRROR_EXTERNAL_MONITOR:-}" ]]; then
    hyprctl monitors -j | jq -r --arg external "$MIRROR_EXTERNAL_MONITOR" '.[] | select(.name == $external) | .name' | head -n 1
    return 0
  fi

  hyprctl monitors -j | jq -r --arg internal "$INTERNAL" '.[] | select(.disabled | not) | select(.name != $internal) | .name' | head -n 1
}

has_active_non_internal_monitor() {
  hyprctl monitors -j | jq -e --arg internal "$INTERNAL" '[.[] | select(.disabled | not) | select(.name != $internal)] | length > 0' >/dev/null
}

INTERNAL="$(resolve_internal_monitor)"
EXTERNAL="$(resolve_external_monitor)"

enable() {
  if [[ -z "$INTERNAL" ]]; then
    notify-send -u low "No laptop monitor found to mirror"
    exit 1
  fi

  if [[ -z "$EXTERNAL" ]] || ! has_active_non_internal_monitor; then
    notify-send -u low "No active external monitor found for mirror"
    exit 1
  fi

  if omarchy-hyprland-toggle-enabled "$DISABLE_TOGGLE"; then
    omarchy-hyprland-toggle "$DISABLE_TOGGLE"
  fi

  if omarchy-hyprland-toggle-disabled "$TOGGLE"; then
    echo "monitor=$EXTERNAL, preferred, auto, 1, mirror, $INTERNAL" >"$TOGGLE_FLAG"
    notify-send -u low "Mirroring enabled ($EXTERNAL)"
    hyprctl reload
  fi
}

disable() {
  if omarchy-hyprland-toggle-enabled "$TOGGLE"; then
    omarchy-hyprland-toggle --disabled-notification "Extended mode restored" "$TOGGLE"
  fi
}

recover() {
  if omarchy-hyprland-toggle-enabled "$TOGGLE" && ! has_active_non_internal_monitor; then
    omarchy-hyprland-toggle "$TOGGLE"
  fi
}

case "${1:-}" in
  on) enable ;;
  off) disable ;;
  toggle)
    if omarchy-hyprland-toggle-enabled "$TOGGLE"; then
      disable
    else
      enable
    fi
    ;;
  recover) recover ;;
  *)
    echo "Usage: $(basename "$0") {on|off|toggle|recover}" >&2
    exit 1
    ;;
esac

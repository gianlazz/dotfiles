#!/bin/bash

# omarchy:summary=Move all workspaces to external monitor when one is connected
# Watches for monitoradded events and migrates workspaces from internal to external.

SOCKET="$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock"

resolve_internal_monitor() {
  if [[ -n "${INTERNAL_MONITOR:-}" ]]; then
    echo "$INTERNAL_MONITOR"
    return
  fi
  hyprctl monitors -j | jq -r '.[] | select(.name | test("^(eDP|DSI|LVDS)")) | .name' | head -n 1
}

move_workspaces_to_external() {
  # Give Hyprland a moment to fully register the new monitor
  sleep 1

  local internal external
  internal="$(resolve_internal_monitor)"
  external="$(hyprctl monitors -j | jq -r --arg internal "$internal" \
    '[.[] | select(.disabled | not) | select(.name != $internal)] | first | .name')"

  if [[ -z "$external" || "$external" == "null" ]]; then
    return
  fi

  hyprctl workspaces -j | jq -r --arg internal "$internal" \
    '.[] | select(.monitor == $internal) | .id' | while read -r ws; do
    hyprctl dispatch moveworkspacetomonitor "$ws" "$external"
  done
}

socat -U - "UNIX-CONNECT:$SOCKET" | while read -r event; do
  case "$event" in
    monitoradded\>\>*|monitoraddedv2\>\>*)
      move_workspaces_to_external
      ;;
  esac
done

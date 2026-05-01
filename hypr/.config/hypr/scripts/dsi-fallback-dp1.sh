#!/bin/bash

INTERNAL="DSI-1"
EXTERNAL="DP-1"
INTERNAL_CONFIG="$INTERNAL,preferred,auto,auto,transform,3"

# Keep a single instance running.
LOCKFILE="/tmp/dsi-fallback-dp1.lock"
exec 9>"$LOCKFILE"
if ! flock -n 9; then
    exit 0
fi

external_connected() {
    hyprctl monitors -j 2>/dev/null | grep -q "\"name\": \"$EXTERNAL\""
}

apply_state() {
    if external_connected; then
        hyprctl keyword monitor "$INTERNAL,disable" >/dev/null 2>&1
    else
        hyprctl keyword monitor "$INTERNAL_CONFIG" >/dev/null 2>&1
    fi
}

while true; do
    # Always enforce the expected state in case another process changes monitors.
    apply_state

    sleep 1
done

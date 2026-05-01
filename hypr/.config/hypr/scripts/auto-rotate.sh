#!/bin/bash

MONITOR="DSI-1"
TOUCHSCREEN="iltp7807:00-222a:fff1"
EXTERNAL="DP-1"

# Keep a single instance running.
LOCKFILE="/tmp/auto-rotate.lock"
exec 9>"$LOCKFILE"
if ! flock -n 9; then
    exit 0
fi

pkill -f "monitor-sensor" 2>/dev/null

monitor-sensor | while read -r line; do
    # If the external display is connected, keep DSI-1 disabled via the
    # fallback script and ignore orientation events.
    if hyprctl monitors -j 2>/dev/null | grep -q "\"name\": \"$EXTERNAL\""; then
        hyprctl keyword monitor "$MONITOR,disable" >/dev/null 2>&1
        continue
    fi

    case "$line" in
        *"orientation changed: normal"*)
            # Landscape (normal laptop/tablet horizontal)
            hyprctl keyword monitor "$MONITOR,preferred,auto,auto,transform,3"
            hyprctl keyword "device[$TOUCHSCREEN]:transform" 3
            ;;
        *"orientation changed: left-up"*)
            # Portrait
            hyprctl keyword monitor "$MONITOR,preferred,auto,auto,transform,0"
            hyprctl keyword "device[$TOUCHSCREEN]:transform" 0
            ;;
        *"orientation changed: right-up"*)
            # Portrait flipped
            hyprctl keyword monitor "$MONITOR,preferred,auto,auto,transform,2"
            hyprctl keyword "device[$TOUCHSCREEN]:transform" 2
            ;;
        *"orientation changed: bottom-up"*)
            # Landscape flipped
            hyprctl keyword monitor "$MONITOR,preferred,auto,auto,transform,1"
            hyprctl keyword "device[$TOUCHSCREEN]:transform" 1
            ;;
    esac
done

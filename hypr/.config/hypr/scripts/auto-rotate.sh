#!/bin/bash

MONITOR="DSI-1"
TOUCHSCREEN="iltp7807:00-222a:fff1"

pkill -f "monitor-sensor" 2>/dev/null

monitor-sensor | while read -r line; do
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

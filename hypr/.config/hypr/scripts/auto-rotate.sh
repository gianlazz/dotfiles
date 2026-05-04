#!/bin/bash
# Listens to iio-sensor-proxy orientation events and applies the corresponding
# Hyprland monitor transform and touchscreen input transform in sync.
# A short debounce prevents rapid sensor bounces from triggering multiple
# expensive monitor reconfigurations during a single physical rotation.

# Target internal panel and touchscreen device identifiers
MONITOR="DSI-1"
TOUCHSCREEN="iltp7807:00-222a:fff1"

# Time (in seconds) to wait after an event before applying the transform.
# Discards intermediate states if the device moves through multiple orientations
# quickly, reducing redundant hyprctl calls.
DEBOUNCE_SECONDS="0.05"

# Tracks the last successfully applied orientation to skip duplicate events,
# and the orientation currently waiting in the debounce window.
last_orientation=""
pending_orientation=""
pending_pid=""

# Apply the Hyprland monitor and touchscreen transforms for a given orientation.
# Both transforms must be updated together to keep touch input aligned with the display.
apply_orientation() {
    local orientation="$1"

    case "$orientation" in
        normal)
            # Landscape (normal laptop/tablet horizontal)
            hyprctl keyword monitor "$MONITOR,preferred,auto,auto,transform,3"
            hyprctl keyword "device[$TOUCHSCREEN]:transform" 3
            ;;
        left-up)
            # Portrait
            hyprctl keyword monitor "$MONITOR,preferred,auto,auto,transform,0"
            hyprctl keyword "device[$TOUCHSCREEN]:transform" 0
            ;;
        right-up)
            # Portrait flipped
            hyprctl keyword monitor "$MONITOR,preferred,auto,auto,transform,2"
            hyprctl keyword "device[$TOUCHSCREEN]:transform" 2
            ;;
        bottom-up)
            # Landscape flipped
            hyprctl keyword monitor "$MONITOR,preferred,auto,auto,transform,1"
            hyprctl keyword "device[$TOUCHSCREEN]:transform" 1
            ;;
        *)
            return 1
            ;;
    esac

    last_orientation="$orientation"
}

# Schedule an orientation change after the debounce window.
# Skips if the orientation matches what's already applied or already pending.
# Cancels any in-flight debounce before scheduling a new one so only the
# most recent orientation is applied.
queue_orientation() {
    local orientation="$1"

    # Skip if already applied or already waiting to be applied
    if [ "$orientation" = "$last_orientation" ] || [ "$orientation" = "$pending_orientation" ]; then
        return 0
    fi

    # Cancel the previous pending apply if it hasn't fired yet
    if [ -n "$pending_pid" ] && kill -0 "$pending_pid" 2>/dev/null; then
        kill "$pending_pid" 2>/dev/null
        wait "$pending_pid" 2>/dev/null
    fi

    pending_orientation="$orientation"
    (
        sleep "$DEBOUNCE_SECONDS"
        apply_orientation "$orientation"
    ) &
    pending_pid=$!
}

# Kill any pending debounce subshell on exit to avoid orphaned background jobs
cleanup() {
    if [ -n "$pending_pid" ] && kill -0 "$pending_pid" 2>/dev/null; then
        kill "$pending_pid" 2>/dev/null
        wait "$pending_pid" 2>/dev/null
    fi
}

trap cleanup EXIT

# Kill any previously running monitor-sensor instance before starting a fresh one
pkill -f "monitor-sensor" 2>/dev/null

monitor-sensor | while read -r line; do
    case "$line" in
        *"orientation changed: normal"*)
            queue_orientation normal
            ;;
        *"orientation changed: left-up"*)
            queue_orientation left-up
            ;;
        *"orientation changed: right-up"*)
            queue_orientation right-up
            ;;
        *"orientation changed: bottom-up"*)
            queue_orientation bottom-up
            ;;
    esac
done

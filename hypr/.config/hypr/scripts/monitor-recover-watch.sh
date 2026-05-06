#!/bin/bash

# Watch Hypr monitor removal events and run user-safe recovery for internal panel.

set -euo pipefail

SOCKET="$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock"

socat -U - "UNIX-CONNECT:$SOCKET" | while read -r event; do
  case "$event" in
    monitorremoved\>\>*|monitorremovedv2\>\>*)
      ~/.config/hypr/scripts/monitor-internal-toggle.sh recover
      ~/.config/hypr/scripts/monitor-internal-mirror-toggle.sh recover
      ;;
  esac
done

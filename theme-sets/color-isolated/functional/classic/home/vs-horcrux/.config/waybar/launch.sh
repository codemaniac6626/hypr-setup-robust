#!/bin/bash

# Define flags
CLOSE_ONLY=false
TOGGLE_MODE=false

# Parse arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --close) CLOSE_ONLY=true ;;
        --toggle) TOGGLE_MODE=true ;;
        *) echo "Unknown parameter passed: $1"; exit 1 ;;
    esac
    shift
done

# --- Toggle Logic ---
if [ "$TOGGLE_MODE" = true ]; then
    if pgrep -x "waybar" > /dev/null; then
        pkill waybar
        echo "Waybar closed via toggle."
    else
        waybar &
        echo "Waybar started via toggle."
    fi
    exit 0
fi

# --- Existing Close/Restart Logic ---

# Kill waybar, ignore error if not running
pkill waybar || true

# If --close was passed, we stop here
if [ "$CLOSE_ONLY" = true ]; then
    echo "Waybar closed."
    exit 0
fi

# Otherwise, proceed with restart
sleep 0.1
waybar &
echo "Waybar restarted."

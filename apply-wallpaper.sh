#!/bin/bash

# $1 is the absolute path to the picture

if [ -z "$1" ]; then
    echo "No wallpaper path provided."
    exit 1
fi

WALLPAPER_PATH="$1"

cp "$WALLPAPER_PATH" "/home/vs-horcrux/wallpaper"

killall hyprpaper 2>/dev/null
pkill hyprpaper 2>/dev/null
sleep 0.5
(uwsm app -- hyprpaper & disown)

echo "Wallpaper applied: $WALLPAPER_PATH"

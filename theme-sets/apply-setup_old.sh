#!/bin/bash

THEME_SET=$1
THEME_TYPE=$2

# --- CONFIGURATION ---
EXPORT_ROOT="/home/vs-horcrux/Desktop/workdir/dots/hypr-setup-robust/theme-sets/$1/$2"

# 1. Clean the input (remove trailing slash if user typed it)
THEME_NAME="${3%/}"
THEME_PATH="$EXPORT_ROOT/$THEME_NAME"

# 2. Safety Check
if [ ! -d "$THEME_PATH" ]; then
    echo "ERROR: Theme '$THEME_NAME' not found."
    exit 1
fi

echo "--- Applying $THEME_TYPE Theme from $THEME_SET theme set: $THEME_NAME ---"

# 3. Apply via cp
# -a: Archive (preserves symlinks, stays recursive, doesn't follow internal symlinks)
# -f: Force (overwrites existing files without asking)
# -n: No-clobber (optional: use -f instead to ensure the theme actually updates)
cp -af "$THEME_PATH/"* /

# 4. Refresh Visuals
if pgrep -x waybar > /dev/null; then
    echo "Refreshing Waybar style..."
    pkill waybar
    waybar & disown
fi

echo "Reloading Hyprland..."
hyprctl reload

killall hyprpaper 2>/dev/null
pkill hyprpaper 2>/dev/null
sleep 0.5

(uwsm app -- hyprpaper & disown)

killall dunst & dunst &

echo "Success! Theme applied."

echo $1 > $EXPORT_ROOT/../../current-set
echo $3 > $EXPORT_ROOT/current-theme

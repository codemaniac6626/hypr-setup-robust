#!/bin/bash

# --- CONFIGURATION ---
EXPORT_ROOT="/home/vs-horcrux/Desktop/workdir/dots/hypr-setup-robust/functional"

# 1. Clean the input (remove trailing slash if user typed it)
THEME_NAME="${1%/}"
THEME_PATH="$EXPORT_ROOT/$THEME_NAME"

# 2. Safety Check
if [ ! -d "$THEME_PATH" ]; then
    echo "ERROR: Theme '$THEME_NAME' not found."
    exit 1
fi

echo "--- Applying Functional Theme: $THEME_NAME ---"

# 3. Apply via cp
# -a: Archive (preserves symlinks, stays recursive, doesn't follow internal symlinks)
# -f: Force (overwrites existing files without asking)
# -n: No-clobber (optional: use -f instead to ensure the theme actually updates)
cp -af "$THEME_PATH/"* /

# 4. Refresh Visuals
if pgrep -x waybar > /dev/null; then
    echo "Refreshing Waybar..."
    pkill -USR2 waybar
fi

echo "Reloading Hyprland..."
hyprctl reload

echo "Success! Theme applied."


echo $1 > $EXPORT_ROOT/current-theme

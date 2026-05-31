#!/usr/bin/env bash

# Get the absolute path of the directory where this script lives
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 1. Load the color database
if [ -f "$BASE_DIR/colors.env" ]; then
    source "$BASE_DIR/colors.env"
else
    echo "Error: colors.env not found in $BASE_DIR" >&2
    exit 1
fi

# 2. Dynamically extract all variables starting with CT_
COLOR_VARS=$(compgen -v CT_ | sed 's/.*/\${&}/' | tr '\n' ',' | sed 's/,$//')

echo "🎨 Compiling theme templates..."

# 3. Compile templates and place outputs exactly where they belong in your tree
envsubst "$COLOR_VARS" < "$BASE_DIR/waybar/colors.css.tpl"   > "$BASE_DIR/waybar/colors.css"
envsubst "$COLOR_VARS" < "$BASE_DIR/rofi/colors.rasi.tpl"    > "$BASE_DIR/rofi/colors.rasi"
envsubst "$COLOR_VARS" < "$BASE_DIR/dunst/colors.conf.tpl"   > "$BASE_DIR/dunst/colors.conf"
envsubst "$COLOR_VARS" < "$BASE_DIR/hypr/colors.conf.tpl"   > "$BASE_DIR/hypr/colors.conf"

# 4. Bridge Dunst to its native runtime drop-in directory
# (This keeps your local folder organized while updating Dunst)
mkdir -p "$HOME/.config/dunst/dunstrc.d"
cp "$BASE_DIR/dunst/colors.conf" "$HOME/.config/dunst/dunstrc.d/colors.conf"

echo "🔄 Refreshing desktop components..."

# 5. Reload running desktop components safely
hyprctl reload
killall -SIGUSR2 waybar
killall dunst && dunst &

echo "✅ Done!"

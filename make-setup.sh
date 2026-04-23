#!/bin/bash

# Check if a theme name was provided
if [ -z "$1" ]; then
    echo "Usage: $0 <theme_name>"
fi

THEME_NAME=$1
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)
TARGET_DIR="$SCRIPT_DIR/$THEME_NAME"
WALLPAPER_SOURCE="$HOME/wallpaper"

echo "Targeting Theme Directory: $TARGET_DIR"

# Create the subdirectory if it doesn't exist
mkdir -p "$TARGET_DIR"

# Function to handle the Yes/No prompt
ask_backup() {
    local name=$1
    local path=$2

    # Ask the user for input
    printf "Include %s in the theme? (y/N): " "$name"
    read -r response

    # Check if response is 'y' or 'Y'
    if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
        if [ -d "$path" ] || [ -f "$path" ]; then
            echo "Copying $name to $THEME_NAME..."
            # Using -rf to ensure it overwrites existing folders/files in the theme subdir
            cp -rf "$path" "$TARGET_DIR/"
        else
            echo "Error: $path not found. Skipping."
        fi
    else
        echo "Skipping $name."
    fi
    echo "-----------------------"
}

# 1. Backup Configs
ask_backup "hypr"   "$HOME/.config/hypr"
ask_backup "waybar" "$HOME/.config/waybar"
ask_backup "rofi"   "$HOME/.config/rofi"
ask_backup "dunst"  "$HOME/.config/dunst"
ask_backup "kitty"  "$HOME/.config/kitty"

# 2. Backup Wallpapers
if [ -f "$WALLPAPER_SOURCE" ]; then
    printf "Include wallpapers from %s? (y/N): " "$WALLPAPER_SOURCE"
    read -r wall_response

    if [[ "$wall_response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
        echo "Saving wallpapers to $THEME_NAME/wallpaper..."
        # Copy all contents of ~/wallpaper to theme/wallpaper
        cp "$WALLPAPER_SOURCE" "$TARGET_DIR"
    else
        echo "Skipping wallpaper backup."
    fi
    echo "-----------------------"
fi

echo "Theme '$THEME_NAME' updated in $TARGET_DIR!!"

#!/bin/bash

# 1. Check if a theme name was provided
if [ -z "$1" ]; then
    echo "Usage: $0 <theme_name>"
    exit 1
fi

THEME_NAME=$1
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)
THEME_PATH="$SCRIPT_DIR/$THEME_NAME"
WALLPAPER_DEST="$HOME"

# 2. Check if the theme directory actually exists
if [ ! -d "$THEME_PATH" ]; then
    echo "Error: Theme directory '$THEME_NAME' not found in $SCRIPT_DIR"
    exit 1
fi

echo "Applying theme: $THEME_NAME"
echo "-----------------------"

# Function to handle the Yes/No prompt and existence check
install_package() {
    local name=$1
    local source_path="$THEME_PATH/$name"
    local dest_path="$HOME/.config/$name"

    if [ -d "$source_path" ]; then
        printf "Install %s configuration? (y/N): " "$name"
        read -r response

        if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
            echo "Installing $name..."
            mkdir -p "$HOME/.config"
            # REDIRECT CP OUTPUT: Some systems/shells alias cp to be chatty
            # Also, Waybar might trigger logs the moment files touch the disk
            cp -rf "$source_path" "$HOME/.config/" > /dev/null 2>&1
        else
            echo "Skipping $name."
        fi
    else
        echo "Notice: $name not found in theme '$THEME_NAME'. Skipping."
    fi
    echo "-----------------------"
}

# 4. Run the prompts
install_package "hypr"
install_package "waybar"
install_package "rofi"
install_package "dunst"
install_package "kitty"

# --- 5. Handle Wallpaper Step ---
if [ -f "$THEME_PATH/wallpaper" ]; then
    printf "Update wallpaper for %s? (y/N): " "$THEME_NAME"
    read -r wall_response

    if [[ "$wall_response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
        echo "Copying wallpaper..."
        cp "$THEME_PATH/wallpaper" "$WALLPAPER_DEST/" > /dev/null 2>&1

        if pgrep -x "hyprpaper" >/dev/null; then
            killall hyprpaper > /dev/null 2>&1
            hyprpaper > /dev/null 2>&1 & disown
            echo "Hyprpaper reloaded."
        fi
    else
        echo "Skipping wallpaper update."
    fi
    echo "-----------------------"
fi

# --- 6. Final Reload Logic ---
# We do this at the very end to catch everything
if pgrep -x "Hyprland" >/dev/null; then
    echo "Refreshing environment..."
    hyprctl reload > /dev/null 2>&1
    
    if pgrep -x "waybar" >/dev/null; then
        killall waybar > /dev/null 2>&1
        # Launching Waybar silently is key
        (waybar > /dev/null 2>&1 &) 
        echo "Waybar restarted."
    fi
fi

echo "Setup for '$THEME_NAME' completed!!"

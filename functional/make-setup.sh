#!/bin/bash

# --- CONFIGURATION ---
# Absolute paths only for pywebview reliability
BASE_DIR="/home/vs-horcrux/Desktop/workdir/dots/hypr-setup-robust/"
MANIFEST="$BASE_DIR/functional-manifest"
EXPORT_ROOT="/home/vs-horcrux/Desktop/workdir/dots/hypr-setup-robust/functional"

# 1. Check for Theme Name
if [ -z "$1" ]; then
    echo "ERROR: No theme name provided."
fi

THEME_NAME="$1"
DEST_DIR="$EXPORT_ROOT/$THEME_NAME"

# 2. Preparation
mkdir -p "$DEST_DIR"

# 3. Execution Logic
echo "Starting Functional Export: $THEME_NAME"

while IFS= read -r line || [ -n "$line" ]; do
    # Trim whitespace/hidden chars
    filepath=$(echo "$line" | xargs)

    # Skip empty lines or comments
    [[ -z "$filepath" || "$filepath" =~ ^# ]] && continue

    if [ -e "$filepath" ]; then
        # Use -a to preserve links/permissions and -R for directories
        # We cd to / so that --parents maps the absolute path correctly into DEST_DIR
	cp --parents -ra "$filepath" "$DEST_DIR/"
        echo "Successfully pooled: $filepath"
    else
        echo "Warning: Path not found -> $filepath"
    fi
done < "$MANIFEST"

echo "------------------------------------------"
echo "Success: Theme saved to $DEST_DIR"


# Update the checkpoint to "Now"
touch $EXPORT_ROOT/.last_sync

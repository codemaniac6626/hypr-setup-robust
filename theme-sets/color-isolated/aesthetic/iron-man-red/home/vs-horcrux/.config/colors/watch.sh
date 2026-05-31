#!/usr/bin/env bash

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_FILE="$BASE_DIR/colors.env"
APPLY_SCRIPT="$BASE_DIR/applycolor.sh"

if ! command -v entr &> /dev/null; then
    echo "Error: 'entr' utility is not installed. Please install it via pacman." >&2
    exit 1
fi

echo "👀 Watching $ENV_FILE for changes..."

# Pipe the env file to entr to trigger apply.sh whenever you save changes
echo "$ENV_FILE" | entr -r "$APPLY_SCRIPT"

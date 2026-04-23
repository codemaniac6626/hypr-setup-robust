#!/usr/bin/env bash

# 1. Use cliphist to list items
# 2. Pass them to Rofi
# 3. Decode the selection and copy it back to the clipboard
cliphist list | rofi -dmenu -p "Clipboard" -theme /home/vs-horcrux/.config/rofi/ai_rofi/cliphist/cliphist.rasi | cliphist decode | wl-copy

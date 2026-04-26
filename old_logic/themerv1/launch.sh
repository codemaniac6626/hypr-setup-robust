#!/bin/bash
# Wrapper script to execute the themer with a specific window class (app-id)
# This allows you to easily target it with Hyprland windowrules!
#
# Example Hyprland rules you can use in your hyprland.conf:
# windowrulev2 = float, class:^(antigravity-themer)$
# windowrulev2 = center, class:^(antigravity-themer)$
# windowrulev2 = size 800 600, class:^(antigravity-themer)$

# Get the directory of this script
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Using 'exec -a' sets the argv[0] of the process. 
# GTK (which pywebview uses on Linux) reads this to set the window class/app-id.
exec -a "antigravity-themer" python3 "$DIR/app.py" & disown     

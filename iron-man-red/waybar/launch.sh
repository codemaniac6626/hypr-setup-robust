#!/bin/bash

# Kill waybar, but ignore the error if it's not running
pkill waybar || true

# Give it a tiny moment to settle
sleep 0.1

# Launch waybar
waybar &

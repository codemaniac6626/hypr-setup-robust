#!/bin/bash

# Options (using Nerd Font icons)
shutdown=""
reboot=""
lock=""
suspend=""
logout="󰍃"

# Get system info (Uptime, CPU, RAM)
uptime=$(uptime -p | sed -e 's/up //g')
cpu=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1}')
mem=$(free -h | awk '/^Mem:/ {print $3}')

# Combine options
options="$lock\n$reboot\n$shutdown\n$suspend\n$logout"

# Launch Rofi
chosen="$(echo -e "$options" | rofi -dmenu \
    -p "System" \
    -mesg "󱑂  $uptime |    $cpu% |   $mem " \
    -theme /home/vs-horcrux/.config/rofi/scripts/powermenu/powermenu.rasi \
    -selected-row 2)" # Default to 'Lock' as in your image

# Execute logic
case $chosen in
    $shutdown) sleep 0.5 && systemctl poweroff ;;
    $reboot) sleep 0.5 && systemctl reboot ;;
    $lock) sleep 0.5 && hyprlock --grace 300 ;; # Or your preferred lockscreen
    $suspend) sleep 0.5 && hyprlock --grace 300 & sleep 0.5 && systemctl suspend ;;
    $logout) sleep 0.5 && hyprctl dispatch exit ;; # Or your WM exit command
esac

hyprctl getoption general:gaps_out | grep -q "0 0 0 0" && (hyprctl keyword general:gaps_out 15; hyprctl keyword general:gaps_in 5) || (hyprctl keyword general:gaps_out 0; hyprctl keyword general:gaps_in 0)

sh ~/.config/waybar/launch.sh --toggle

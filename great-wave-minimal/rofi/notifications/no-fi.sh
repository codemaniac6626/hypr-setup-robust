MSG="$@"

timeout 3s rofi -theme ~/.config/rofi/notifications/notification.rasi -e "$MSG" &

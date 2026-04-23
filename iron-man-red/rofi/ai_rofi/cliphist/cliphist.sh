#!/usr/bin/env bash

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)
HIST_FILE="$SCRIPT_DIR/.clipboard_history.txt"
PID_FILE="$SCRIPT_DIR/.daemon.pid"
SEP=" ↵ "

# Function to clean up children (like sleep) when the script is killed
cleanup() {
    echo "Stopping daemon..."
    rm -f "$PID_FILE"
    # Kill all child processes of this script
    pkill -P $$ 
    exit 0
}

case "$1" in
    --daemon)
        # Check if already running
        if [ -f "$PID_FILE" ] && kill -0 $(cat "$PID_FILE") 2>/dev/null; then
            echo "Daemon is already running (PID: $(cat "$PID_FILE"))."
            exit 1
        fi

        # Save current PID to file
        echo $$ > "$PID_FILE"
        
        # If the script receives a SIGTERM or SIGINT, run the cleanup function
        trap cleanup SIGTERM SIGINT

        last_clip=""
        while true; do
            current_clip=$(xsel -ob 2>/dev/null)
            if [[ -n "${current_clip//[[:space:]]/}" && "$current_clip" != "$last_clip" ]]; then
                flattened=$(printf '%s' "$current_clip" | sed -z "s/\n/$SEP/g" | sed "s/$SEP$//")
                TMP_FILE=$(mktemp)
                grep -vFx "$flattened" "$HIST_FILE" > "$TMP_FILE" 2>/dev/null
                ( printf "%s\n" "$flattened"; cat "$TMP_FILE" ) | head -n 10 > "$HIST_FILE.new"
                mv "$HIST_FILE.new" "$HIST_FILE"
                rm -f "$TMP_FILE"
                last_clip="$current_clip"
            fi
            sleep 1 & wait $! # 'wait' allows the trap to trigger immediately
        done
        ;;

    --stop)
        if [ -f "$PID_FILE" ]; then
            PID=$(cat "$PID_FILE")
            echo "Killing daemon at PID $PID"
            kill "$PID"
            rm -f "$PID_FILE"
        else
            echo "No PID file found. Try: pkill -f rofi-clip.sh"
        fi
        ;;

    *)
        # UI Selection mode remains the same
        selected=$(head -n 10 "$HIST_FILE" | rofi -theme "/home/sriram/.config/rofi/ai_rofi/cliphist/cliphist.rasi" -dmenu -i -p "Clipboard" -l 10)
        if [[ -n "$selected" ]]; then
            decoded=$(printf '%s' "$selected" | sed "s/$SEP/\n/g")
            printf "%s" "$decoded" | xsel -ib
        fi
        ;;
esac

conf() {
    if [ -z "$1" ]; then
        cd ~/.config || return
    else
        # Directs you to ~/.config/your-argument
        cd ~/.config/"$1" 2>/dev/null || echo "Directory ~/.config/$1 not found."
    fi
}

# --- Simple Mark/Jump System ---
MARK_STORAGE="$HOME/.bookmarks"

mark() {
  local type="dir"
  local target=""
  local alias=""

  if [[ "$1" == "-f" ]]; then
    type="file"
    target=$(realpath "$2")
    alias="$3"
  else
    target=$(realpath "$1")
    alias="$2"
  fi

  if [[ -z "$alias" ]]; then
    echo "Usage: mark <folder> <alias>  OR  mark -f <file> <alias>"
    return 1
  fi

  touch "$MARK_STORAGE"
  # Remove existing alias if it exists
  sed -i "/ $alias$/d" "$MARK_STORAGE"
  # Store: TYPE TARGET ALIAS
  echo "$type $target $alias" >> "$MARK_STORAGE"
  echo "Saved: $alias -> $target"
}

jump() {
  local entry=$(grep " $1$" "$MARK_STORAGE")
  if [[ -z "$entry" ]]; then
    echo "Alias '$1' not found."
    return 1
  fi

  local type=$(echo "$entry" | cut -d' ' -f1)
  local target=$(echo "$entry" | cut -d' ' -f2)

  if [[ "$type" == "file" ]]; then
    vim "$target"
  else
    cd "$target" || echo "Directory not found."
  fi
}

marks() {
  if [[ ! -s "$MARK_STORAGE" ]]; then echo "No marks set."; return; fi
  printf "%-10s %-15s %-s\n" "ALIAS" "TYPE" "PATH"
  printf "%-10s %-15s %-s\n" "-----" "----" "----"
  while read -r type path alias; do
    printf "%-10s %-15s %-s\n" "$alias" "$type" "$path"
  done < "$MARK_STORAGE"
}

clear_marks() {
  if [[ "$1" == "-" ]]; then
    > "$MARK_STORAGE"
    echo "All marks cleared."
  elif [[ -n "$1" ]]; then
    sed -i "/ $1$/d" "$MARK_STORAGE"
    echo "Cleared alias: $1"
  else
    echo "Usage: clear <alias>  OR  clear -"
  fi
}

# Alias 'clear' is often taken by the system, so we use a function
# but you can rename this to whatever you prefer.
alias clear-mark='clear_marks'

reason() {
    # 1. Configuration
    local LOG_DIR="$HOME/cmd_logs"
    local METADATA_FILE="$LOG_DIR/activity_history.log"
    mkdir -p "$LOG_DIR"

    # 2. Parse Flags
    local user_reason=""
    local OPTIND=1  # Reset getopts in case it was used previously in the shell

    while getopts "t:" opt; do
        case "$opt" in
            t) user_reason="$OPTARG" ;;
            *) echo "Usage: reason [-t 'your reason'] command"; return 1 ;;
        esac
    done
    shift $((OPTIND - 1)) # Remove the parsed options from the positional parameters

    # 3. Capture the Reason Interactively if not provided via flag
    if [[ -z "$user_reason" ]]; then
        echo -n "Why are you running this? "
        read -r user_reason
        if [[ -z "$user_reason" ]]; then
            echo "Reason is required to proceed."
            return 1
        fi
    fi

    # 4. Check if a command was actually provided
    local cmd="$*"
    if [[ -z "$cmd" ]]; then
        echo "Error: No command specified to run."
        return 1
    fi

    # 5. Prepare Command and Filenames
    local timestamp=$(date "+%Y-%m-%d %H:%M:%S")
    local file_safe_ts=$(date "+%Y%m%d_%H%M%S")
    local output_log="$LOG_DIR/output_$file_safe_ts.log"

    # 6. Log the Metadata
    {
        echo "----------------------"
        echo "Timestamp: $timestamp"
        echo "Reason: $user_reason"
        echo "Command/Script: $cmd"
        echo "LogFileName: $output_log"
        echo "----------------------"
        echo ""
    } >> "$METADATA_FILE"

    # 7. Execute and Capture Output
    script -q -c "$cmd" "$output_log"
}

extctl() {
    local action=$1
    local target=$2
    local mount_base="/mnt"

    # Your Transcend StoreJet ID
    local disk_id="usb-StoreJet_Transcend_1FD755460FFF-0:0"

    case "$action" in
        m)
            if [ -n "$target" ]; then
                echo "Mounting specific target: $target..."
                sudo mount "$mount_base/$target"
            else
                echo "Mounting all external partitions..."
                sudo mount -a
            fi
            ;;
        u)
            if [ -n "$target" ]; then
                echo "Unmounting $target..."
                sudo umount "$mount_base/$target"
            else
                echo "Unmounting all ext_* and stopping motor..."
                sudo umount /mnt/ext_*
		sleep 2
                # Resolve physical disk node to stop vibration
                local dev_node=$(readlink -f /dev/disk/by-id/$disk_id)
                if [ -b "$dev_node" ]; then
                    udisksctl power-off -b "$dev_node"
                    echo "󱊟 Drive $dev_node powered down."
                else
                    echo "󱊟 Error: Transcend drive not found."
                fi
            fi
            ;;
        *)
            echo "Usage: extctl {m|u} [partition_name]"
            echo "Examples:"
            echo "  extctl m             (Mount all & auto-fix)"
            echo "  extctl u             (Unmount all & kill vibration)"
            echo "  extctl m ext_samples (Mount specific)"
            ;;
    esac
}

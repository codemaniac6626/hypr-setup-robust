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

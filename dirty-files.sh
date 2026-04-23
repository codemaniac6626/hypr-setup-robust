#!/bin/bash

# --- PATHS ---
AESTHETIC_MANIFEST="/home/vs-horcrux/Desktop/workdir/dots/hypr-setup-robust/aesthetic-manifest"
FUNCTIONAL_MANIFEST="/home/vs-horcrux/Desktop/workdir/dots/hypr-setup-robust/functional-manifest"

# Checkpoints
AESTHETIC_SYNC="/home/vs-horcrux/Desktop/workdir/dots/hypr-setup-robust/aesthetic/.last_sync"
FUNCTIONAL_SYNC="/home/vs-horcrux/Desktop/workdir/dots/hypr-setup-robust/functional/.last_sync"

# Function to check a manifest against a sync file
check_dirty() {
    local manifest=$1
    local sync_file=$2
    local pool_name=$3

    echo "[$pool_name Pool]"
    
    if [ ! -f "$sync_file" ]; then
        echo "  ! No sync record found. Everything is technically 'new'."
        # Create a fake old timestamp so everything shows up as dirty
        sync_file="/dev/null" 
    fi

    local dirty_count=0

    while IFS= read -r line || [ -n "$line" ]; do
        filepath=$(eval echo "$line" | xargs)
        [[ -z "$filepath" || "$filepath" =~ ^# ]] && continue

        # Handle Wildcards/Patterns
        expanded_paths=$(eval echo "$filepath")
        for path in $expanded_paths; do
            if [ -e "$path" ]; then
                # -nt means "newer than"
                if [ "$path" -nt "$sync_file" ]; then
                    # Get relative path for cleaner UI
                    display_path=${path#/home/vs-horcrux/}
                    echo "  󰏫  DIRTY: /$display_path"
                    ((dirty_count++))
                fi
            fi
        done
    done < "$manifest"

    if [ $dirty_count -eq 0 ]; then
        echo "  󰄵  All files synced."
    fi
    echo ""
}

# --- EXECUTION ---
echo "--- RICE STATUS REPORT ---"
echo "Checking for unsaved changes since last 'make-setup'..."
echo ""

# Check both pools
check_dirty "$AESTHETIC_MANIFEST" "$AESTHETIC_SYNC" "Aesthetic"
check_dirty "$FUNCTIONAL_MANIFEST" "$FUNCTIONAL_SYNC" "Functional"

echo "--------------------------"

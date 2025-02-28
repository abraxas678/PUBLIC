#!/bin/bash

# Check if a directory was provided.
if [[ -z "$1" ]]; then
    echo "Usage: $0 <directory>"
    exit 1
fi

dir="$1"

# Verify that the directory exists.
if [[ ! -d "$dir" ]]; then
    echo "Error: Directory \"$dir\" not found."
    exit 1
fi

# Gather scripts from directory.
# Here we assume all scripts have a .sh extension.
scripts=()
for file in "$dir"/*.sh; do
    if [[ -f "$file" ]]; then
        scripts+=("$(basename "$file")")
    fi
done

if [[ ${#scripts[@]} -eq 0 ]]; then
    dialog --msgbox "No scripts found in $dir" 5 40
    clear
    exit 1
fi

# Build options list for dialog checklist.
# Each option has: tag, description and default status ("on" means selected by default).
dialog_options=()
for scr in "${scripts[@]}"; do
    dialog_options+=("$scr" "$scr" "on")
done

# Let the user select/deselect scripts.
selected=$(dialog --checklist "Select scripts (use SPACE to select/deselect, ENTER to confirm):" 15 50 0 \
    "${dialog_options[@]}" 3>&1 1>&2 2>&3)
exit_status=$?
if [ $exit_status -ne 0 ]; then
    clear
    exit 1
fi

# Convert the resulting string into an array.
# This assumes filenames have no spaces.
IFS=' ' read -r -a selected_scripts <<< "$selected"

if [ ${#selected_scripts[@]} -eq 0 ]; then
    dialog --msgbox "No scripts selected." 5 30
    clear
    exit 1
fi

# ------------------------------------------------------------------------------
# Function: reorder_selection
# Adjusted positions/sizes for 80-column terminals with proper focus handling
# ------------------------------------------------------------------------------
reorder_selection() {
    local arr=("$@")
    local new_order=()
    local remaining=("${arr[@]}")
    local choice
    local tmpfile
    tmpfile=$(mktemp /tmp/order.XXXXXX)
    
    # Right panel: columns 40-79 (width 40), aligned top
    dialog --begin 0 40 --tailboxbg "$tmpfile" 20 40 &
    local tailbox_pid=$!

    while [ ${#remaining[@]} -gt 0 ]; do
        # Update temporary file
        {
          echo "Current order:"
          if [ ${#new_order[@]} -gt 0 ]; then
              printf "%s\n" "${new_order[@]}"
          else
              echo "(empty)"
          fi
        } > "$tmpfile"

        # Left panel: columns 0-39 (width 40)
        menu_options=()
        for idx in "${!remaining[@]}"; do
            menu_options+=("$idx" "${remaining[$idx]}")
        done
        
        # Add explicit OK/Cancel buttons
        choice=$(dialog --begin 0 0 --menu "Remaining scripts:" 20 40 10 \
            "${menu_options[@]}" \
            --and-widget --extra-button --extra-label "Done" \
            3>&1 1>&2 2>&3)
            
        # Handle selection or cancellation
        if [ $? -eq 0 ]; then
            new_order+=("${remaining[$choice]}")
            unset 'remaining[$choice]'
            remaining=("${remaining[@]}")
        else
            break
        fi
    done

    kill "$tailbox_pid" 2>/dev/null
    rm -f "$tmpfile"
    echo "${new_order[@]}"
}

# ------------------------------------------------------------------------------
# Let the user reorder the selected scripts if more than one was selected.
# This uses the interactive menu-based reordering function above.
# ------------------------------------------------------------------------------
if [ ${#selected_scripts[@]} -gt 1 ]; then
    dialog --yesno "Would you like to manually arrange the order of the selected scripts?" 8 50 3>&1 1>&2 2>&3
    if [ $? -eq 0 ]; then
        ordered=$(reorder_selection "${selected_scripts[@]}")
        # Only update the order if the user completed an ordering.
        IFS=' ' read -r -a temp_order <<< "$ordered"
        if [ ${#temp_order[@]} -eq ${#selected_scripts[@]} ]; then
            selected_scripts=("${temp_order[@]}")
        fi
    fi
fi

# Build final ordered list for display and for saving to the result file.
final_list=""
for i in "${!selected_scripts[@]}"; do
    final_list+="$((i+1)): ${selected_scripts[$i]}\n"
done

dialog --msgbox "Final order of scripts:\n$final_list" 15 50

# Save the final ordered list to a file.
result_file="$(dirname "$0")/ordered_scripts.txt"
echo -e "$final_list" > "$result_file"
dialog --msgbox "Order has been saved to:\n$result_file" 10 50

# ------------------------------------------------------------------------------
# Allow the user to modify the order of the items just saved.
# The same menu-based reordering (with the two-box layout) is provided here.
# ------------------------------------------------------------------------------
while true; do
    dialog --yesno "Would you like to modify the order of the saved scripts?" 8 50 3>&1 1>&2 2>&3
    ret_status=$?
    if [ $ret_status -ne 0 ]; then
         break
    fi

    ordered=$(reorder_selection "${selected_scripts[@]}")
    IFS=' ' read -r -a temp_order <<< "$ordered"
    if [ ${#temp_order[@]} -eq ${#selected_scripts[@]} ]; then
         selected_scripts=("${temp_order[@]}")
    fi

    final_list=""
    for i in "${!selected_scripts[@]}"; do
         final_list+="$((i+1)): ${selected_scripts[$i]}\n"
    done

    dialog --msgbox "Updated order of scripts:\n$final_list" 15 50 3>&1 1>&2 2>&3
    echo -e "$final_list" > "$result_file"
done
# ------------------------------------------------------------------------------

clear
exit 0

#!/bin/bash

read_with_timeout() {
    local input=""
    local timeout=0.4  # Timeout in seconds for each character
    local total_timeout=6000000  # Total timeout in seconds
    local char
    local start_time=$(date +%s)
    
    while true; do
        if read -t $timeout -n 1 char; then
            input+="$char"
            start_time=$(date +%s)  # Reset the start time when input is received
        else
            current_time=$(date +%s)
            elapsed=$((current_time - start_time))
            
            if [ $elapsed -ge $total_timeout ]; then
                no_input_action
                break
            elif [ -z "$input" ]; then
                continue  # No input yet, keep waiting
            else
                break  # Input stopped, exit loop
            fi
        fi
    done
    echo "$input"
}

no_input_action() {
printf ""
#    echo "No input received after 10 seconds. Performing default action." >&2
    # Add your desired action here
#    TITLE="$(go-chromecast -a 192.168.11.110 status | sed 's/.*title="//' | sed 's/", artist.*//')"
#    echo $TITLE >/home/abrax/.config/polybar/current_playing_title.txt
#    TITLE=$(printf "%-77.77s" "$TITLE")
#    tput cup 1 0; echo $TITLE
}

result=$(read_with_timeout)

# Output the result in a way that can be captured by the parent shell
echo "$result"

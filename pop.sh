#!/bin/bash
v1="$1"
echo $v1 >pop.txt
BLUE='\033[1;34m'
GRAY='\033[1;90m'
GREEN='\033[1;32m'
NC='\033[0m'

# Check for xdotool
if ! command -v xdotool &> /dev/null; then
    echo "xdotool is required. Please install it first."
    exit 1
fi

# Check for wmctrl
if ! command -v wmctrl &> /dev/null; then
    echo "wmctrl is required. Please install it first."
    exit 1
fi

# Determine which terminal emulator to use
if command -v gnome-terminal &> /dev/null; then
    TERMINAL="gnome-terminal"
elif command -v xterm &> /dev/null; then
    TERMINAL="xterm"
else
    echo "No suitable terminal emulator found"
    exit 1
fi

# Create a temporary script with the popup content
TMP_SCRIPT=$(mktemp)
cat << 'EOF' > "$TMP_SCRIPT"
#!/bin/bash
BLUE='\033[1;34m'
GRAY='\033[1;90m'
GREEN='\033[1;32m'
NC='\033[0m'

tput civis
echo -ne "${BLUE}┌────────────────────────────────┐\n${BLUE}└─➤${GREEN} NOTIFICATION: $(cat pop.txt)${BLUE}    ${NC}"
read -n 1
tput cnorm
clear
EOF

chmod +x "$TMP_SCRIPT"

# Launch terminal
case $TERMINAL in
    "gnome-terminal")
        $TERMINAL --title="popup" -- bash "$TMP_SCRIPT" &
        ;;
    "xterm")
        xterm -title "popup" -e bash "$TMP_SCRIPT" &
        ;;
esac

# Wait for window to appear
sleep 0.5

# Force resize using wmctrl
wmctrl -r "popup" -e 0,0,0,350,50

# Wait for script to finish
wait

# Clean up
rm "$TMP_SCRIPT"



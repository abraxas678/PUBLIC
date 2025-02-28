if confirm_step "Install basic dependencies"; then
    isinstalled curl
    isinstalled wget
    isinstalled unzip
    isinstalled shred
fi
echothis "Installing basic utilities"
$MYSUDO apt update
$MYSUDO apt install -y xdotool wmctrl xsel curl unzip ccrypt git
isinstalled xsel
isinstalled fzf
isinstalled gron

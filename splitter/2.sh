#!/bin/bash
###########2. Define Functions

# Get current release version
CUR_REL=$(curl -L start.yyps.de | grep "echo version:" | sed 's/echo version: NEWv//')
NEW_REL=$((CUR_REL + 1))

# Print current and new release versions
echo "CUR_REL: $CUR_REL"
echo "NEW_REL: $NEW_REL"

# Install a package if not already installed
installme() {
which $@ > /dev/null
if [[ $? != 0 ]]; then
echo -e "${YELLOW}INSTALL: $1${RESET}"
countdown 1
sudo apt install -y $1
fi
}

# Install Homebrew and its dependencies
brew_install() {
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
export PATH="/home/linuxbrew/.linuxbrew/bin:$PATH"
sudo apt-get install -y build-essential
brew install gcc
echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> $MYHOME/.zshrc
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
exec zsh
export ANS=n
}

# Wait for a new release
release_wait() {
while true; do
echo "WAITING FOR RELEASE"
sleep 5
CUR_REL=$(curl -L start.yyps.de | grep "echo version:" | sed 's/echo version: NEWv//')
echo "$CUR_REL $NEW_REL"
[[ $CUR_REL == $NEW_REL ]] && break
done
echo "Release ready"
exit
}

# Check if user wants to wait for the next release
VERS="n"
read -t 5 -n 1 -p "[W]AIT FOR NEXT RELEASE - v$NEW_REL? >>" VERS
[[ $VERS == "w" ]] && release_wait
echo

# Check DNS and connectivity
check_dns() {
echo "check_dns"
cd $HOME
sudo ping -c 1 google.com > /dev/null && echo "Online" || echo "Offline"
sudo ping -c 1 google.com > /dev/null && ONL=1 || ONL=0
if [[ $ONL == 0 ]]; then
CHECK=$(cat /etc/resolv.conf)
if [[ $CHECK != *"8.8.8.8"* ]] ; then
echo "DNS is not set to 8.8.8.8"
fi
sudo ping -c 1 google.com > /dev/null && echo "Online" || echo "Offline"
fi
}

# Print header1
header1(){
echo -e "${YELLOW}$@${RESET}"
}

# Print header2
header2(){
TEXT=$(echo "$@" | tr '[:lower:]' '[:upper:]')
echo -e "${LIGHT_BLUE}$TEXT${RESET}"
}

# Countdown function
countdown() {
if [ -z "$1" ];then
echo "No argument provided. Please provide a number to count down from."
exit 1
fi

tput civis
for ((i=$1; i>0; i--)); do
if (( i > $1*66/100 )); then
echo -ne "${GREEN}$i${RESET}\r"
elif (( i > $1*33/100 )); then
echo -ne "${YELLOW}$i${RESET}\r"
else
echo -ne "${RED}$i${RESET}\r"
fi
sleep 1
echo -ne "\033[0K"
done
echo -e "${RESET}"
tput cnorm
}

# Task function with header and countdown
TASK() {
echo
header1 "$@"
countdown 1
}

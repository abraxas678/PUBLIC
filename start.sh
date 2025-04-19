#!/bin/bash
clear
echo v0.1
sleep 1
clear

header1() {
  tput cup $x 0
  export v1="$@"
  echo -e "\e[1;38;5;34m╭─ \e[1;38;5;39m$@\e[0m"
  echo -e "\e[1;38;5;34m╰─ \e[2;38;5;245m[$(date +%H:%M:%S)]\e[0m"
}
header2() {
  RES=$?
  sleep 2
  x=$((x+1))
  [[ $RES = 0 ]] && tput cup $x 3; tput ed
  [[ $RES = 0 ]] && echo -e "\e[1;38;5;46m󰄬 [COMPLETED]\e[0m" ||  echo -e "\e[1;38;5;196m󰅙 [FAILED]\e[0m"
  x=$((x+2))
}

# Determine if sudo is needed for commands
if [[ "$(whoami)" == "root" ]]; then
    MYSUDO=""
else
    MYSUDO="sudo"
fi

x=1
header1 "apt update"
$MYSUDO apt update
header2
header1 "apt install curl"
$MYSUDO apt install -y curl wget nano
header2
header1 "apt upgrade -y"
$MYSUDO apt upgrade -y
header2
header1 "create ram folder"
mkdir $HOME/tmp/ram -p 
$MYSUDO mount -t tmpfs -o size=100M tmpfs $HOME/tmp/ram
header2
header1 "snas check"
cd $HOME/tmp/ram
curl -L https://192.168.0.5:5443/envs -O --insecure
header2

source $HOME/tmp/ram/envs

header1 "chezmoi.tar"
curl -L https://192.168.0.5:5443/chezmoi.tar -O --insecure
mkdir -p $HOME/.config/chezmoi/
$MYSUDO mv $HOME/tmp/ram/chezmoi.tar $HOME/.config/chezmoi/
cd $HOME/.config/chezmoi/
$MYSUDO tar xf chezmoi.tar
header2
header1 "move .config/chezmoi"
 $MYSUDO mv $HOME/.config/chezmoi/$HOME/.config/chezmoi/* $HOME/.config/chezmoi/
header2
header1 "install chezmoi"
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply $GITHUB_USERNAME
header2

$MYSUDO mv $HOME/.config/chezmoi/bin/chezmoi /usr/bin/





echo
exit
# Function to display a completion message in cyan
# Usage: header2 "Task Description"

# Function to display a main header message with a timestamp
# Usage: header1 "Section Title"

# Function to display a sub-header or status message
# Usage: header0 "Status update or sub-task"
header0() {
  echo -e "\e[1;38;5;34m╰─ \e[2;38;5;245m[$@]\e[0m"
}

create_header() {
   echo
}


# --- Script Execution Starts Here ---
# Example  Usage (Uncomment or add your own steps):
 header1 "Starting Setup"
 header0 "Updating packages..."
 sleep 2 # Simulate work
 header2 "Packages Updated"
 header1 "Setup Complete"

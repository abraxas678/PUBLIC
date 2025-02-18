#!/bin/bash

# Determine if sudo is needed for commands
if [[ "$(whoami)" == "root" ]]; then
    MYSUDO=""
else
    MYSUDO="sudo"
fi

# Function to display a completion message in cyan
echothis2() {
  local message="$1"
  echo -e "\e[1;36m└─ 󰄬 $message [COMPLETED]\e[0m"
}

# Function to display a header message with a timestamp
echothis() {
  echo -e "\e[1;38;5;34m╭─ \e[1;38;5;39m$@\e[0m"
  echo -e "\e[1;38;5;34m╰─ \e[2;38;5;245m[$(date +%H:%M:%S)]\e[0m"
  echo ""
}

# Function to check if a command is installed and install it if not
isinstalled() {
  local pkg="$1"
  echo ""
  echothis "[isinstalled] Checking for $pkg"
  
  if ! command -v "$pkg" >/dev/null 2>&1; then
      echo ""
      echo "[TASK]_________ INSTALLING $pkg"
      echo ""
      echo "........... Updating package lists"
      echo ""
      $MYSUDO apt update
      echo ""
      echo "........... Installing $pkg"
      echo ""
      $MYSUDO apt install -y "$pkg"
  else
      echo ""
      echo "[INFO]______ $pkg is already installed."
      echo ""
  fi
  
  echothis2 "$pkg"
}

# Clear the terminal and display version
clear
echo "V0.0.6"
sleep 1

# Create temporary directory and navigate to it
mkdir -p "$HOME/tmp"
cd "$HOME/tmp" || exit

# Clone or update the public repository
if [[ ! -d "$HOME/tmp/public" ]]; then
  echo ""
  echothis "[TASK]_____ CLONING public.git"
  git clone https://github.com/abraxas678/public.git
else
  echo ""
  echothis "[TASK]_____ Updating public.git"
  cd "$HOME/tmp/public" || exit
  git pull origin master
fi

# Ensure curl is installed
isinstalled curl

# Change directory to the public repository
cd "$HOME/tmp/public" || exit

# Check if Tabby is installed; if not, install it from the latest GitHub release
if ! command -v tabby >/dev/null 2>&1; then
  echothis "Installing Tabby..."
  # Retrieve the latest release URL for Tabby
  URL=$( "$HOME/tmp/public/github_latest_release_url.sh" Eugeny tabby | tail -n1 )
  cd "$HOME/tmp" || exit
  echo "Downloading Tabby from: $URL"
  sleep 3
  wget "$URL"
  $MYSUDO apt install "$HOME/tmp/$(basename "$URL")"
fi

# Display instructions to execute the start script
echo ""
echo "===================================================="
echo "___>>> EXECUTE"
echo "               $HOME/tmp/public/start.sh"
echo ""
echo "===================================================="
echo ""
notify-send "now run  /home/abrax/tmp/public/start.sh"
# Launch Tabby terminal if available
if command -v tabby >/dev/null 2>&1; then
  tabby
else
  echo "Error: Tabby is not installed."
fi


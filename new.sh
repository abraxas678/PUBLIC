#!/bin/bash
clear
echo "v0.0.1"
sleep 1

mkdir -p $HOME/tmp
cd $HOME/tmp || exit

# Determine if sudo is needed for commands
if [[ "$(whoami)" == "root" ]]; then
    MYSUDO=""
else
    MYSUDO="sudo"
fi

# Function to display a header message with a timestamp
echothis() {
  echo -e "\e[1;36;5;34m╭─ \e[1;38;5;39m$@\e[0m"
  echo -e "\e[1;36;5;34m╰─ \e[2;38;5;245m[$(date +%H:%M:%S)]\e[0m"
}

# Function to display a completion message in cyan
echothis2() {
  local message="$1"
  echo -e "\e[1;36m└─ $message [COMPLETED]\e[0m"
}
echothis3() {
  local message="$1"
  echo -e "\e[1;36m[────── $message ──────]\e[0m"
}

isinstalledcheck() {
  if ! command -v $1 1>del 2>del; then echo no; else echo yes; fi
}
isinstalled() {
     echothis "checking $1"
     sleep 1
  if [[ $(isinstalledcheck "$1") = "no" ]]; then
     echothis "installing $1"
     sudo apt install "$1"
     [[ $? = 0 ]] && echothis2 "$1 sucessfully installed" || echothis2 "there was an issue with installation of $1"
  else
     echothis2 "$1 already installed"; 
  fi
}

isinstalled thorium-browser
[[ $(isinstalledcheck thorium-browser) = "yes" ]] && [[ $(isinstalledcheck firefox-esr) = "yes" ]] && sudo apt purge firefox-esr -y
if [[ $(isinstalledcheck thorium-browser) = "yes" ]]; then
  if [[ $(isinstalledcheck gh) = "no" ]]; then
    isinstalled gh
    gh auth login
  fi
fi
isinstalled curl
isinstalled git
isinstalled gh
isinstalled nano

CHECK=$(isinstalledcheck chezmoi)
if [[ $CHECK != "yes" ]]; then 
    echothis2 "installing chezmoi"; 
    $HOME/tmp/public/github_latest_release_url.sh twpayne chezmoi >url
    URL=$(cat url | tail -n1)
    echothis3 "URL; $URL"; 
    wget "$URL"
    $MYSUDO apt install -y $HOME/tmp/$(basename $URL)
else
     echothis2 "chezmoi already installed"; 
fi

#kopia.sh
CHECK=$(isinstalledcheck chezmoi)
if [[ $CHECK != "yes" ]]; then 
  echothis2 "installing kopia"; 
  curl -s https://kopia.io/signing-key | sudo gpg --dearmor -o /etc/apt/keyrings/kopia-keyring.gpg
  echo "deb [signed-by=/etc/apt/keyrings/kopia-keyring.gpg] http://packages.kopia.io/apt/ stable main" | sudo tee /etc/apt/sources.list.d/kopia.list
  sudo apt update
  sudo apt install kopia
  sudo apt install kopia-ui
else
     echothis2 "kopia already installed"; 
fi

echothis "CHEZMOI INIT"
chezmoi init --ssh --apply abraxas678

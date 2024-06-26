#!/bin/bash
#####################1. Initialization and Environment Setup
mkdir -p ~/tmp
cd ~/tmp

clear
MYHOME=$HOME
echo "MYHOME=$MYHOME"
cd $HOME

# Print version
echo "version: NEWv14"
sleep 1

# Color definitions
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
PURPLE='\033[0;35m'
ORANGE='\033[0;33m'
GREY='\033[0;37m'
LIGHT_BLUE='\033[1;34m'
RESET='\033[0m'
RC='\033[0m'

source /home/abrax/bin/header.sh
source /home/abrax/bin/countdown.sh

installme() {
  which $@ > /dev/null
  if [[ $? != 0 ]]; then
    echo -e "${YELLOW}INSTALL: $1${RESET}"
    countdown 1
    sudo apt install -y $1
  fi
}


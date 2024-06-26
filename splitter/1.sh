#!/bin/bash
##1. Initialization and Environment Setup

# Clear the terminal
clear

# Set home directory variable
MYHOME=$HOME
echo "MYHOME=$MYHOME"

# Pause for 1 second
sleep 1

# Change to home directory
cd $HOME

# Print version
echo "version: NEWv14"

# Print sync files and rclone config
echo
echo "cd $MYHOME/bin/
up sync.sh
up down.sh
up sync.txt
up header.sh
up header2.sh
up ~/.config/rclone/rclone.conf"
echo

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

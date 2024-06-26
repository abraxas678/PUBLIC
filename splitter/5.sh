#!/bin/bash
##5. User setup #5. User setup && APT update#5. User setup && APT update APT update  && last update time
# Task: Check if user is 'abrax'
TASK "CHECK: USER = abrax?"
if [[ $USER != *"abrax"* ]]; then
sudo apt install -y sudo
if [[ $USER == *"root"* ]]; then
su abrax
adduser abrax
usermod -aG sudo abrax
su abrax
exit
else
su abrax
sudo adduser abrax
sudo usermod -aG sudo abrax
su abrax
exit
fi
fi

# Task: Check last apt update time
TASK "check last update time"
ts=$(date +%s)
if [[ -f ~/last_apt_update.txt ]]; then
DIFF=$(($ts - $(cat ~/last_apt_update.txt)))
if [[ $DIFF -gt 6000 ]]; then
sudo apt update && sudo apt upgrade -y
fi
else
sudo apt update && sudo apt upgrade -y
fi
echo $ts > ~/last_apt_update.txt

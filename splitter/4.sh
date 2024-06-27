#!/bin/bash
##4. User setup
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


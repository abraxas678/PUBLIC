#!/bin/bash
#13. Rclone Configuration    rclone setup
# Set up rclone

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
if [[ ! -f $MYHOME/.config/rclone/rclone.conf ]]; then
mkdir -p $MYHOME/.config/rclone
curl https://rclone.org/rclone.conf -o $MYHOME/.config/rclone/rclone.conf
echo -e "${YELLOW}EDIT: rclone.conf${RESET}"
read -p "Press any key to continue..." -n1 -s
vim $MYHOME/.config/rclone/rclone.conf
fi

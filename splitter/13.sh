#!/bin/bash
##13. Rclone Configuration
# Set up rclone
TASK "check: rclone"
if [[ ! -f $MYHOME/.config/rclone/rclone.conf ]]; then
mkdir -p $MYHOME/.config/rclone
curl https://rclone.org/rclone.conf -o $MYHOME/.config/rclone/rclone.conf
echo -e "${YELLOW}EDIT: rclone.conf${RESET}"
read -p "Press any key to continue..." -n1 -s
vim $MYHOME/.config/rclone/rclone.conf
fi

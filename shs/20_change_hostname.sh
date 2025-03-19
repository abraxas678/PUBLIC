#!/bin/bash
# Hostname configuration
tput civis
echo -e "\e[1;34m┌──── Machine Name Configuration\e[0m"
echo -e "\e[1;34m│\e[0m"
echo -e "\e[1;34m│ Current hostname: \e[1;33m$CURRENT_HOSTNAME\e[0m"
echo -e "\e[1;34m└─➤\e[0m \e[1;37mWould you like to change this machine's hostname? (y/n):\e[0m"
read -n 1 CHANGE_HOSTNAME
echo

case $CHANGE_HOSTNAME in
  [Yy]*)
    echo -e "\e[1;34m┌──── Enter New Hostname\e[0m"
    echo -e "\e[1;34m│\e[0m"
    echo -e "\e[1;34m└─➤\e[0m \e[1;37mNew hostname:\e[0m"
    read NEW_HOSTNAME
    echo -e "\e[1;34m│ Changing hostname to: $NEW_HOSTNAME\e[0m"
    $MYSUDO hostnamectl set-hostname "$NEW_HOSTNAME"
    $MYSUDO sed -i "s/127.0.1.1.*/127.0.1.1\t$NEW_HOSTNAME/g" /etc/hosts
    echo -e "\e[1;32m└─➤ Hostname updated successfully\e[0m"
    ;;
  *)
    echo -e "\e[1;37m└─➤ Keeping current hostname\e[0m"
    ;;
esac
tput cnorm

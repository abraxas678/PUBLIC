#!/bin/bash
clear
echo -e "\e[1;34m┌─ Start.sh v0.6\e[0m"
sleep 3
ts=$(date +%s)

MYHOME=$HOME
MYPWD=$PWD
echo MYHOME $MYHOME
echo MYPWD $MYPWD
sleep 3
echo

sudo apt update && sudo apt upgrade -y
sudo apt install nfs-common

read -p "snas 192.168. >> " IP0
IP="192.168.$IP0"

mkdir $MYPWD/startsh_snas; sudo mount -t nfs $IP:/volume2/startsh_snas $MYPWD/startsh_snas

[[ -f $MYPWD/.startsh_snas/env ]] && echo "sucessfully mounted"



isinstalled() {
  me=y
  if ! command -v $1 >/dev/null 2>&1; then
    echo -e "\e[1;34m┌─ 󰏗 Installing $1...\e[0m"
    sudo apt-get update
    sudo apt-get install -y "$1"
    echo -e "\e[1;36m└─ 󰄬 $1 installation completed\e[0m"
  else
    echo -e "\e[1;34m└─ 󰄬 $1 is already installed\e[0m"
  fi
}

git config --global user.email "$MYEMAIL"
git config --global user.name "$MYUSERNAME"

isinstalled git
isinstalled gh

gh auth login

mkdir $HOME/tmp
cd $HOME/tmp

gh repo clone start.sh

exit

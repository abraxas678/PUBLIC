#!/bin/bash
clear
echo -e "\e[1;34m┌─ public Start.sh v0.8\e[0m"
sleep 3

echothis() {
  echo -e "\e[1;34m--$@\e[0m"
}

ts=$(date +%s)

MYHOME=$HOME
MYPWD=$PWD
echo
echothis MYHOME $MYHOME
echothis MYPWD $MYPWD
sleep 3
echo

sudo apt update && sudo apt upgrade -y
sudo apt install nfs-common -y
echo
echothis "USER INPUT:"
read -p "snas 192.168. >> " IP0
IP="192.168.$IP0"

mkdir $MYPWD/startsh_snas; sudo mount -t nfs $IP:/volume2/startsh_snas $MYPWD/startsh_snas

source $MYPWD/startsh_snas/env

echo
if [[ -f $MYPWD/startsh_snas/env ]]; then
  echothis "sucessfully mounted" 
else
  echothis "not mounted" 
  exit
fi

sleep 1
echo


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

isinstalled ccrypt

echothois "long num 2x"

mkdir $HOME/.ssh -p
cp $MYPWD/startsh_snas/bws.dat.cpt $HOME/.ssh/
ccrypt -d $MYPWD/.ssh/startsh_snas/bws.dat.cpt


isinstalled git
isinstalled gh

git config --global user.email "$MYEMAIL"
git config --global user.name "$MYUSERNAME"

STAT="$(gh auth login)"
[[ *"$STAT"* != *"Logged in to github.com account abraxas678"* ]] && gh auth login

mkdir $HOME/tmp
cd $HOME/tmp

echothis "cloning startsh"
gh repo clone startsh

echo
echo "startsh/start2.sh"
echo
chmod +x $HOME/tmp/startsh/start2.sh
$HOME/tmp/startsh/start2.sh

echo DONE

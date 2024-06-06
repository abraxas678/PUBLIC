#!/bin/bash
read -s PHRASE
read -s PHRASE2
echo ${#PHRASE}
[[ ${#PHRASE} != 55 ]] && exit
echo ${#PHRASE2}
[[ ${#PHRASE2} != 51 ]] && exit
sleep 1
exit

sudo apt update
sudo apt install -y nodejs
sudo apt install -y npm
sudo npm install -g vault
sleep 1
clear

sudo timedatectl set-timezone Europe/Berlin
sleep 1; printf "your time now: "; sudo hwclock --show
sleep 2

sudo docker kill sshwifty
sudo docker rm sshwifty

sudo docker run --detach \
  --restart always \
  --publish 8872:8182 \
  --name sshwifty \
  niruix/sshwifty:latest

curl -d "start http://$(tailscale ip | head -n 1):8872" https://pcopy.dmw.zone/exec -L

curl -L "https://triggercmd.com/sb?b=pBupzjZPa00qX33D" >/dev/null 2>&1


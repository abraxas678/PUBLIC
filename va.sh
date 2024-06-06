#!/bin/bash
#https://github.com/jcoglan/vault
read -s PHRASE
read -s PHRASE2
echo ${#PHRASE}
[[ ${#PHRASE} != 55 ]] && exit
echo ${#PHRASE2}
[[ ${#PHRASE2} != 51 ]] && exit
sleep 1
A=1
B=1
C=1
which nodejs > /dev/null || A=0
which npm > /dev/null || B=0
which vault > /dev/null || C=0
D=$((A+B+C))
if [[ $D != 3 ]]; then
  sudo apt update
  sudo apt install -y nodejs
  sudo apt install -y npm
  sudo npm install -g vault
fi
sleep 1
clear




if [[ 1 = 2 ]]; then
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

fi

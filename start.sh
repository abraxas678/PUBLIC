#!/bin/bash
## version 0.1
PMANAGER=apt
cd $HOME
mkdir tmp -p
cd tmp
$PMANAGER update
$PMANAGER install curl wget python3-pip pipx micro git gh -y
curl -fsSL https://tailscale.com/install.sh | sh
git config --global user.email "abraxas678@gmail.com"
git config --global user.name "abraxas678"
sudo -v ; curl https://rclone.org/install.sh | sudo bash -s beta
[[ $(gh auth status) != *"Logged in to github.com account abraxas678"* ]] && gh auth login

cd $HOME
[[ ! -d webapps ]] && gh repo clone webapps
[[ ! -d bin ]] && gh repo clone bin
source /home/abrax/bin/header.sh
[[ ! -d tmpconfig ]] && gh repo clone .config tmpconfig
rclone move tmpconfig/ .config/ --update -P
#rm -rf tmpconfig

pip install rich-cli
[[ $? != 0 ]] && [[ $(pipx list) != *"- rich"* ]] && pipx install rich-cli && pipx ensurepath && exec bash


cd ~/webapps/script_runner/
git pull
chmod +x *.sh
chmod +x ./shs/*.sh
#mkdir /home/abrax/bin/ -p
cd $HOME
#cp 02_fix_letter_or_number.sh /home/abrax/bin/letter_or_number.sh 
#source 01_fix_create_scripts.sh
#source ./create_script.sh
echo
echo script_runner
echo
/bin/bash $HOME/webapps/script_runner/script_runner.sh

exit

#!/bin/bash
## version 0.1

isinstalled() {
  command -v $1 >/dev/null 2>&1 || { echo >&2 "$1 is not installed. Installing..."; sleep 2; sudo apt-get update; sudo apt-get update && sudo apt-get install -y $1; }
}

doit() {
  tput civis
  me=y
  rich -p "EXECUTE [blue]$1[/blue] ? (y/n) >>" -a heavy -s green
  read -s -n 1 -t 10 me
  [[ -z $2 ]] && INSTALL="$1" || INSTALL="$2"
  [[ $me = y ]] && $INSTALL
  tput cnorm
}
[[ $(whoami) != "root" ]] && PMANAGER="sudo apt" || PMANAGER="apt"
tput cup 0 0
tput ed
cd $HOME
mkdir tmp -p
cd tmp
isinstalled git
isinstalled gh
git config --global user.email "abraxas678@gmail.com"
git config --global user.name "abraxas678"
[[ $(gh auth status) != *"Logged in to github.com account abraxas678"* ]] && doit "gh auth login"


exit
pipx install rich-cli
pipx ensurepath
echo "pipx ensurepath done"
doit "$PMANAGER update"
doit "$PMANAGER install curl wget micro git gh unzip nano -y"
doit tailscale "wget https://tailscale.com/install.sh"
 chmod +x install.sh; 
./install.sh
sudo -v ; curl https://rclone.org/install.sh | sudo bash -s beta

cd $HOME
[[ ! -d webapps ]] && doit "gh repo clone webapps"
chmod +x $HOME/webapps/script_runner/shs/*
AKEYLESS="$(ls $HOME/webapps/script_runner/shs/*akeyless.sh)"
doit akeyless "$AKEYLESS"
GETSSH="$(ls $HOME/webapps/script_runner/shs/*get_ssh.sh)"
doit "GET SSH KEYS" "$GETSSH"
[[ ! -d bin ]] && doit "gh repo clone bin"
source /home/abrax/bin/header.sh
[[ ! -d tmpconfig ]] && doit "gh repo clone .config tmpconfig && rclone move tmpconfig/ .config/ --update -P"
#rm -rf tmpconfig

#pip install rich-cli
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

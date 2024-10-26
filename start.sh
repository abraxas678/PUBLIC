#!/bin/bash
## version 0.3
clear
echo version 0.4
sleep 3
ts=$(date +%s)

isinstalled() {
  me=y
# read -t 2 -p "INSTALL $1? (y/n) >> " me
#  if [[ $me = y ]]; then
    command -v $1 >/dev/null 2>&1 || { echo >&2 "$1 is not installed. Installing..."; sleep 2; sudo apt-get update; sudo apt-get update && sudo apt-get install -y $1; }
#  fi
}

isinstalled python3-pip
isinstalled pipx

CHECK="$(pipx list | grep -v grep | grep -v hishtory | grep rich | wc -l)"
if  [[ $CHECK = 0 ]]; then
  pipx install rich-cli
  pipx ensurepath
  echo "pipx ensurepath done"; sleep 1
  echo $ts >/home/abrax/tmp/pipxinstall.done
fi

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

isinstalled unzip 
isinstalled xsel

### BWS
wget https://github.com/bitwarden/sdk/releases/download/bws-v1.0.0/bws-x86_64-unknown-linux-gnu-1.0.0.zip
unzip bws-x86_64-unknown-linux-gnu-1.0.0.zip
sudo mv bws /usr/bin/
rm -f bws-x86_64-unknown-linux-gnu-1.0.0.zip
bws config server-base https://vault.bitwarden.eu

### ###

isinstalled yad

echo; rich -p "PROVIDE:  ~/.ssh/bws.dat, just paste" -a heavy -e -s red
if [ -f ~/.ssh/bws.dat ]; then
  echo -e "${COLORS[BLUE]}Copying content of ~/.ssh/bws.dat to clipboard...${COLORS[NC]}"
  cat ~/.ssh/bws.dat | tee /dev/tty | xsel -b
  echo -e "${COLORS[GREEN]}Content copied to clipboard successfully.${COLORS[NC]}"
fi
bws=$(yad --title="Secure Password Input" \
              --text="BWS:" \
              --entry \
              --hide-text \
              --width=300 \
              --button="OK:0" \
              --button="Cancel:1" \
              --center)
mkdir -p ~/.ssh/
echo $bws >~/.ssh/bws.dat
chmod 600 ~/.ssh/*
chmod 700 ~/.ssh

isinstalled git
isinstalled gh
isinstalled zoxide

git config --global user.email "abraxas678@gmail.com"
git config --global user.name "abraxas678"

[[ $(gh auth status) != *"Logged in to github.com account abraxas678"* ]] && doit "gh auth login"
cd $HOME; mkdir webapps -p
cd $HOME/webapps
echo; echo "clone start.sh repo START"
[[ ! -d start.sh ]] && doit "gh repo clone start.sh"
echo; echo "clone start.sh repo DONE"
sleep 2
rich -p "$(ls start.sh)" -a rounded -s blue

read -p BUTTON me

cd /home/abrax/webapps/script_runner/shs
EXE="$(ls *akeyless*)"
command -v akeyless || ./$EXE
cd $HOME
[[ ! -d bin ]] && doit "gh repo clone bin"
source /home/abrax/bin/header.sh
command -v rclone || sudo -v ; curl https://rclone.org/install.sh | sudo bash -s beta

## CONFIG COPY
#[[ ! -d tmpconfig ]] && gh repo clone .config tmpconfig && rclone move tmpconfig/ .config/ --update -P

#exit
doit "$PMANAGER update"
doit "$PMANAGER install curl wget micro git gh unzip nano -y"
doit tailscale "wget https://tailscale.com/install.sh;  chmod +x install.sh; ./install.sh"

chmod +x $HOME/webapps/script_runner/shs/*
#AKEYLESS="$(ls $HOME/webapps/script_runner/shs/*akeyless.sh)"
#doit akeyless "$AKEYLESS"
#chmod +x /home/abrax/bin/akeyless
#sudo cp /home/abrax/bin/akeyless /usr/bin
chmod +x  /home/abrax/webapps/script_runner/db
sudo cp  /home/abrax/webapps/script_runner/db /usr/bin
cp  /home/abrax/webapps/script_runner/db /home/abrax/bin/

GETSSH="$(ls $HOME/webapps/script_runner/shs/*get_ssh.sh)"
doit "GET SSH KEYS" "$GETSSH"
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

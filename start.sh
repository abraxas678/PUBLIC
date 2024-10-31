#!/bin/bash
clear
echo -e "\e[1;34m┌─ Start.sh v0.6\e[0m"
sleep 3
ts=$(date +%s)

MYHOME=$HOME
echo MYHOME $MYHOME

if [[ 1 = 2 ]]; then
# Check if running as abrax, if not, switch to abrax
if [[ $(whoami) != "abrax" ]]; then
    echo -e "\e[1;34m┌─ 󰏗 Switching to user abrax...\e[0m"
    # Create user if it doesn't exist
    if ! id -u abrax >/dev/null 2>&1; then
        echo -e "\e[1;34m├─ 󰏗 Creating user abrax first...\e[0m"
        sudo useradd -m -s /bin/bash abrax
        echo -e "\e[1;36m├─ 󰄬 User abrax created\e[0m"
    fi
    echo -e "\e[1;36m└─ 󰄬 Executing script as abrax\e[0m"
    exec sudo -u abrax bash "$0" "$@"
    exit 0  # This line won't be reached due to exec
fi

# Install Homebrew
if ! command -v brew >/dev/null 2>&1; then
  echo -e "\e[1;34m┌─ 󰏗 Installing Homebrew...\e[0m"
  NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  
  # Add Homebrew to PATH for the current session and permanently
  test -d ~/.linuxbrew && eval "$(~/.linuxbrew/bin/brew shellenv)"
  test -d /home/linuxbrew/.linuxbrew && eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
  
  # Add to shell rc file if not already present
  if ! grep -q "eval \"\$($(brew --prefix)/bin/brew shellenv)\"" ~/.bashrc; then
    echo "eval \"\$($(brew --prefix)/bin/brew shellenv)\"" >> ~/.bashrc
  fi
  
  echo -e "\e[1;36m└─ 󰄬 Homebrew installation completed\e[0m"
  sleep 2
else
  echo -e "\e[1;34m└─ 󰄬 Homebrew is already installed\e[0m"
fi
fi

# Install gum
if ! command -v gum >/dev/null 2>&1; then
  echo -e "\e[1;34m┌─ 󰏗 Installing gum...\e[0m"
  brew install gum
  echo -e "\e[1;36m└─ 󰄬 gum installation completed\e[0m"
  sleep 2
else
  echo -e "\e[1;34m└─ 󰄬 gum is already installed\e[0m"
fi

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

isinstalled python3-pip
isinstalled pipx

CHECK="$(pipx list | grep -v grep | grep -v hishtory | grep rich | wc -l)"
if  [[ $CHECK = 0 ]]; then
  pipx install rich-cli
  pipx ensurepath
  echo "pipx ensurepath done"; sleep 1
  echo $ts >$MYHOME/tmp/pipxinstall.done
fi

doit() {
  tput civis
  me=y
  echo -e "\e[1;34m┌─ 󰏗 Action required:\e[0m"
  rich -p "EXECUTE [blue]$1[/blue] ? (y/n) >>" -a heavy -s green
  read -s -n 1 -t 10 me
  [[ -z $2 ]] && INSTALL="$1" || INSTALL="$2"
  if [[ $me = y ]]; then
    echo -e "\e[1;36m│ Executing command...\e[0m"
    $INSTALL
    echo -e "\e[1;36m└─ 󰄬 Command completed\e[0m"
  else
    echo -e "\e[1;31m└─ ✗ Command skipped\e[0m"
  fi
  tput cnorm
}
[[ $(whoami) != "root" ]] && PMANAGER="sudo apt" || PMANAGER="apt"

tput cup 0 0
tput ed
cd $MYHOME
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
  echo -e "\e[1;36m│ Copying content of ~/.ssh/bws.dat to clipboard...\e[0m"
  cat ~/.ssh/bws.dat | tee /dev/tty | xsel -b
  echo -e "\e[1;36m└─ 󰄬 Content copied successfully\e[0m"
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
#cd $MYHOME; mkdir webapps -p
#cd $MYHOME/webapps
cd $MYHOME
echo; echo "clone start.sh repo START"
[[ ! -d start.sh ]] && doit "gh repo clone start.sh"
echo; echo "clone start.sh repo DONE"
sleep 2
rich -p "$(ls start.sh)" -a rounded -s blue

read -p BUTTON me

exit
#############################################

cd $MYHOME/start.sh/script_runner/shs
EXE="$(ls *akeyless*)"
command -v akeyless || ./$EXE
cd $MYHOME
[[ ! -d bin ]] && doit "gh repo clone bin"
source $MYHOME/bin/header.sh
command -v rclone || sudo -v ; curl https://rclone.org/install.sh | sudo bash -s beta

## CONFIG COPY
#[[ ! -d tmpconfig ]] && gh repo clone .config tmpconfig && rclone move tmpconfig/ .config/ --update -P

#exit
doit "$PMANAGER update"
doit "$PMANAGER install curl wget micro git gh unzip nano -y"
doit tailscale "wget https://tailscale.com/install.sh;  chmod +x install.sh; ./install.sh"

chmod +x $MYHOME/start.sh/script_runner/shs/*
#AKEYLESS="$(ls $MYHOME/start.sh/script_runner/shs/*akeyless.sh)"
#doit akeyless "$AKEYLESS"
#chmod +x $MYHOME/bin/akeyless
#sudo cp $MYHOME/bin/akeyless /usr/bin
chmod +x  $MYHOME/start.sh/script_runner/db
sudo cp  $MYHOME/start.sh/script_runner/db /usr/bin
cp  $MYHOME/start.sh/script_runner/db $MYHOME/bin/

GETSSH="$(ls $MYHOME/start.sh/script_runner/shs/*get_ssh.sh)"
doit "GET SSH KEYS" "$GETSSH"
#rm -rf tmpconfig

#pip install rich-cli
[[ $? != 0 ]] && [[ $(pipx list) != *"- rich"* ]] && pipx install rich-cli && pipx ensurepath && exec bash


cd ~/start.sh/script_runner/
git pull
chmod +x *.sh
chmod +x ./shs/*.sh
#mkdir $MYHOME/bin/ -p
cd $MYHOME
#cp 02_fix_letter_or_number.sh $MYHOME/bin/letter_or_number.sh 
#source 01_fix_create_scripts.sh
#source ./create_script.sh
echo
echo script_runner
echo
/bin/bash $MYHOME/start.sh/script_runner/script_runner.sh

exit

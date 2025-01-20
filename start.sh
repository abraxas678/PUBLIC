#!/bin/bash
clear

# Check if package is installed, install if not
isinstalled() {
  if ! command -v $1 >/dev/null 2>&1; then
    echo -e "\e[1;34m┌─ 󰏗 Installing $1...\e[0m"
    gum spin --spinner="points" --title="apt update..." --spinner.foreground="33" --title.foreground="33" $MYSUDO apt-get update > /dev/null 2>&1
    #gum spin --spinner="points" --title="apt install..." --spinner.foreground="33" --title.foreground="33" 
    $MYSUDO apt-get install -y "$1" 
    [[ $? = 0 ]] && clear
    echo -e "\e[1;36m└─ 󰄬 $1 installation completed\e[0m"
  else
    echo -e "\e[1;34m└─ 󰄬 $1 is already installed\e[0m"
  fi
}

cd $HOME
[[ "$(whoami)" = "root" ]] && MYSUDO="" || MYSUDO="sudo"

$MYSUDO apt update
[[ $? = 0 ]] && clear
isinstalled curl

#$MYSUDO apt install -y wget curl
#[[ $? = 0 ]] && clear

command -v gum >del
if [[ $? != 0 ]]; then
  wget https://github.com/charmbracelet/gum/releases/download/v0.14.5/gum_0.14.5_amd64.deb
  echo -e "\e[1;34m┌─ 󰏗 Installing gum...\e[0m"
  $MYSUDO apt install -y ./gum_0.14.5_amd64.deb
  [[ $? = 0 ]] && clear && echo -e "\e[1;34m┌─ 󰏗 Installing gum...\e[0m" && echo -e "\e[1;36m└─ 󰄬 $1 installation completed\e[0m"
fi

MYUSER="$(gum write --height=1 --prompt=">> " --no-show-help --placeholder="$(whoami)" --header="USER:" --value="$(whoami)")"
echo "MYUSER=$MYUSER"
sleep 5

mkdir -p ~/.ssh
mkdir -p ~/tmp

echothis() {
  gum spin --spinner="pulse" --title="" --spinner.foreground="33" --title.foreground="33" sleep 1
  echo -e "\e[1;38;5;34m╭─ \e[1;38;5;39m$@\e[0m"
  echo -e "\e[1;38;5;34m╰─ \e[2;38;5;245m[$(date +%H:%M:%S)]\e[0m"
  gum spin --spinner="pulse" --title="" --spinner.foreground="33" --title.foreground="33" sleep 1
#  tput cuu1
  gum spin --spinner="dot" --title="." --spinner.foreground="33" --title.foreground="33" sleep 0.3
  gum spin --spinner="dot" --title=".." --spinner.foreground="33" --title.foreground="33" sleep 0.3
  gum spin --spinner="dot" --title="..." --spinner.foreground="33" --title.foreground="33" sleep 0.3
#  tput cuu1
#  gum spin --spinner="pulse" --title=".." --spinner.foreground="33" --title.foreground="33" sleep 1
#  tput cuu1
#  gum spin --spinner="pulse" --title="..." --spinner.foreground="33" --title.foreground="33" sleep 1
sleep 2
}

echothis2() {
  echo -e "\e[1;36m└─ 󰄬 $1 installation completed\e[0m"
}


mkdir -p $HOME/tmp/
cd $HOME/tmp/

echo; echo; echo; echo; echo;
# Check if user $MYUSER exists
echothis "Check if user $MYUSER exists"
if [[ $(whoami) != "$MYUSER" ]]; then
if ! id "$MYUSER" >/dev/null 2>&1; then
  echothis "Creating user $MYUSER..."
  $MYSUDO useradd -m -s /bin/bash $MYUSER
  # Set password for $MYUSER user (you may want to change this)
  echo "$MYUSER:$MYUSER" | $MYSUDO chpasswd
  # Add $MYUSER to sudo group
  $MYSUDO usermod -aG sudo $MYUSER
  echothis2 "User $MYUSER created"
else
  echothis "User $MYUSER already exists"
fi

# Switch to $MYUSER user if not already
if [ "$(whoami)" != "$MYUSER" ]]; then
echo
#  echothis "Switching to user $MYUSER..."
#  exec $MYSUDO -u $MYUSER "$0" "$@"
fi
fi

#[[ "$(whoami)" != "$MYUSER" ]] && echo "not $MYUSER. exit." && exit

[[ $(whoami) = "root" ]] && MYSUDO="" || MYSUDO="sudo"

echo
echothis "START.SH INSTALLATION"

command -v brave-browser >del
if [[ $? != 0 ]]; then
  echo -e "\e[1;34m┌─ 󰏗 Installing brave...\e[0m"
  echo 'curl -fsS https://dl.brave.com/install.sh | sh' >brave.sh
  chmod +x brave.sh
  gum spin --spinner="points" --title="Brave Browser..." --spinner.foreground="33" --title.foreground="33" -- ./brave.sh
  [[ $? = 0 ]] && clear && echo -e "\e[1;34m┌─ 󰏗 Installing brave...\e[0m" && echo -e "\e[1;36m└─ 󰄬 brave installation completed\e[0m"
fi

[[ $(cat ~/.ssh/bws.dat | wc -l) = 0 ]] && rm ~/.ssh/bws.dat
if [[ ! -f ~/.ssh/bws.dat ]]; then
echo
read -p BUTTON me
[[ ! -f ~/.ssh/bws.dat ]] && brave-browser https://github.com/abraxas678 &
[[ ! -f ~/.ssh/bws.dat ]] && brave-browser https://bitwarden.eu &
[[ ! -f ~/.ssh/bws.dat ]] && gum input --password --no-show-help --placeholder="enter bws.dat" >~/.ssh/bws.dat
export BWS_ACCESS_TOKEN=$(cat ~/.ssh/bws.dat)
echo
fi

# Environment setup
export DISPLAY=:0
export PATH="$HOME/bin:$PATH"

echothis "installing essentials"
isinstalled wget
sleep 0.5
isinstalled curl
sleep 0.5
isinstalled unzip
sleep 0.5
isinstalled shred

#sleep 0.5
#isinstalled keepassxc


# BWS INSTALL
command -v bws >/dev/null 2>&1
if [[ $? != 0 ]]; then
echothis "BWS INSTALL"
gum spin --spinner="points" --title="downloading BWS..." --spinner.foreground="33" --title.foreground="33" wget https://github.com/bitwarden/sdk/releases/download/bws-v1.0.0/bws-x86_64-unknown-linux-gnu-1.0.0.zip
gum spin --spinner="points" --title="unzipping BWS..." --spinner.foreground="33" --title.foreground="33"  unzip bws-x86_64-unknown-linux-gnu-1.0.0.zip
gum spin --spinner="points" --title="move..." --spinner.foreground="33" --title.foreground="33" $MYSUDO mv bws /usr/bin/
rm -f bws-x86_64-unknown-linux-gnu-1.0.0.zip
fi
echothis "updating BWS server-base"
bws config server-base https://vault.bitwarden.eu >$HOME/tmp/del 2>&1
echothis2 "$(cat $HOME/tmp/del)"
rm -f $HOME/tmp/del

chmod 700 ~/.ssh
chmod 600 ~/.ssh/*

echothis "edit visudo"
[[ $($MYSUDO cat /etc/sudoers | grep -v grep | grep "$MYUSER ALL=(ALL) NOPASSWD: ALL" | wc -l) = 0 ]] && echo "$MYUSER ALL=(ALL) NOPASSWD: ALL" | $MYSUDO EDITOR=nano tee -a /etc/sudoers

[[ ! -f /opt/Tabby/tabby ]] && brave-browser https://github.com/Eugeny/tabby/releases/tag/v1.0.219 &
echo
read -p BUTTON me
#echothis "ENTER to continue to bws. create a new key"
#read
#open https://vault.bitwarden.eu/
#read -p "Press ENTER to continue"

# Securely prompt for BWS API key
#echothis "Enter your Bitwarden API key"
#echo -e "\e[1;33mNote: Input will not be displayed for security\e[0m"

#Create secure memory-only tmpfs mount
#SECURE_DIR=$(mktemp -d)
#sudo mount -t tmpfs -o size=1m,mode=700 tmpfs "$SECURE_DIR"
#KEYFILE="$SECURE_DIR/key"
#sudo touch "$KEYFILE"
#sudo chmod 600 "$KEYFILE"

# Trap to ensure cleanup
trap '$MYSUDO umount "$SECURE_DIR" 2>/dev/null; $MYSUDO rm -rf "$SECURE_DIR" 2>/dev/null' EXIT

# Read key securely with timeout and clear screen after
#read -p ">> " -s -t 60 BWS_API_KEY
#echo
#clear

# Validate the API key is not empty
#while [[ -z "$BWS_API_KEY" ]]; do
#  echo -e "\e[1;31mAPI key cannot be empty\e[0m"
#  echo -e "\e[1;33mPlease enter your Bitwarden API key:\e[0m"
#  read -s -t 60 BWS_API_KEY
#  echo
#  clear
#done

# Write key to secure tmpfs file
#sudo chown $MYUSER: -R $KEYFILE
#sudo chown $MYUSER: -R /tmp
#sudo echo "$BWS_API_KEY" > "$KEYFILE"

#https://public.yyps.de/bwkdb.cpt
#bitwarden_cli.keyx
#bitwarden_cli.kdbx
#https://vault.bitwarden.eu/#/sm/d395420e-f43a-4abc-8b97-b207008b2984/machine-accounts/6373f7ec-cc8c-400e-863b-b207008c27ff/projects
#https://www.slimjetbrowser.com/release/slimjet_amd64.deb
#https://chromewebstore.google.com/detail/proton-pass-free-password/ghmbeldphafepmbegfdlkpapadhbakde
#https://chromewebstore.google.com/detail/bitwarden-password-manage/nngceckbapebfimnlniiiahkandclblb


#find_key() {
#  rclone ls snas:sec_bws/bitwarden_cli.keyx >/dev/null 2>&1
#  [[ $? != 0 ]]
#}

# Clear variables and bash history
#BWS_API_KEY=""
#history -c
#set +o history

# Configure BWS using secure file
#bws config set access-token "$(sudo cat "$KEYFILE")"
#[[ $? != 0 ]] && echo "could not set access-token" && exit 1

# Immediately shred and remove keyfile
#shred -u "$KEYFILE"

# Unmount secure tmpfs
#sudo umount "$SECURE_DIR"
#sudo rm -rf "$SECURE_DIR"

# Re-enable history
#set -o history
# User setup and sudo configuration
export TAILSCALE_INSTALL="1dee0b6b-63d1-45b3-887e-b23100e3f9dc"
export LOCAL_USER="7d0b08f5-72aa-43a4-80d0-b246016256d7"
export GITHUB_USERNAME="380f19b0-171a-4cd5-a826-b24601628d1d"
export LOCAL_EMAIL="9305523b-c74f-4f06-a0de-b2460162d05a"


echothis install chezmoi
#which bws >/dev/null 2>&1
#[[ $? = 0 ]] && bws run -- sh -c "$(curl -fsLS get.chezmoi.io)" 
#[[ $? = 0 ]] && bws run -- ~/bin/chezmoi init --apply abraxas678
wget https://github.com/twpayne/chezmoi/releases/download/v2.58.0/chezmoi_2.58.0_linux_amd64.deb
sudo apt install -y ./chezmoi_2.58.0_linux_amd64.deb


# Install basic utilities
echothis "Installing basic utilities"
$MYSUDO apt update
$MYSUDO apt install -y xdotool wmctrl xsel curl unzip age ccrypt git gh

# Configure git
bws run -- git config --global user.email "$MYEMAIL"
bws run -- git config --global user.name "$GITHUB_USERNAME"

if [[ 1 = 2 ]]; then
# System setup type selection
tput civis
echo -e "\e[1;34m┌──── System Setup Type\e[0m"
echo -e "\e[1;34m│\e[0m"
echo -e "\e[1;34m└─➤\e[0m \e[1;37mAre you setting up a (L)ocal machine or a (S)erver?\e[0m"
read -n 1 SETUP_TYPE
echo

case $SETUP_TYPE in
  [Ll]*)
    MACHINE_TYPE="local"
    echo -e "\e[1;32m└─➤ Local machine setup selected\e[0m"
    ;;
  [Ss]*)
    MACHINE_TYPE="server"
    echo -e "\e[1;32m└─➤ Server setup selected\e[0m"
    ;;
  *)
    echo -e "\e[1;31m└─➤ Invalid selection. Defaulting to local setup\e[0m"
    MACHINE_TYPE="local"
    ;;
esac
tput cnorm
fi

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

echo
echo "https://github.com/login/device/select_account"
echo
# GitHub authentication
if ! gh auth status &>/dev/null; then
    echo -e "\e[1;34m┌──── GitHub Authentication\e[0m"
    echo -e "\e[1;34m│\e[0m"
    echo -e "\e[1;34m└─➤\e[0m \e[1;37mLogging in to GitHub...\e[0m"
    gh auth login
else
    echo -e "\e[1;34m└─➤\e[0m \e[1;37mGitHub authentication already configured\e[0m"
fi

# Clone public repo and setup
mkdir -p $HOME/tmp
cd $HOME/tmp
if [ ! -d "public" ]; then
  gh repo clone public
else
  cd public
  git pull
fi

# Install bws if needed
#command bws >/dev/null 2>&1 || /home/abrax/tmp/public/bws.sh

mkdir -p /home/$MYUSERNAME/.config/chezmoi
bws run -- 'echo "$chezmoi_toml"' >/home/$MYUSER/.config/chezmoi/chezmoi.toml
bws run -- 'echo "$tailscale_setup"' >/home/$MYUSER/tmp/tailscale_setup.sh
chmod +x /home/$MYUSER/tmp/tailscale_setup.sh
echo


# Configure chezmoi
#cp chezmoi.toml.cpt /home/$MYUSERNAME/.config/chezmoi
#cd /home/$MYUSERNAME/.config/chezmoi
#ccrypt --decrypt chezmoi.toml.cpt

echo -e "\e[1;34m┌──── Initializing Chezmoi\e[0m"
echo -e "\e[1;34m│\e[0m"
echo -e "\e[1;34m└─➤\e[0m \e[1;37mCloning dotfiles from GitHub...\e[0m"
chezmoi init --apply abraxas678 --ssh

echo -e "\e[1;34m┌──── Applying Changes\e[0m"
echo -e "\e[1;34m│\e[0m"
echo -e "\e[1;34m└─➤\e[0m \e[1;37mExecuting 'chezmoi update' to apply dotfile changes...\e[0m"
chezmoi update
echo -e "\e[1;32m└─➤ Changes applied successfully\e[0m"
tput cnorm

# Install Unmanic if requested
tput civis
#echo -e "\e[1;34m┌──── Unmanic Installation\e[0m"
#echo -e "\e[1;34m│\e[0m"
#echo -e "\e[1;34m└─➤\e[0m \e[1;37mWould you like to install Unmanic? (y/n):\e[0m"
#read -n 1 INSTALL_UNMANIC
#echo

#case $INSTALL_UNMANIC in
#  [Yy]*)
#    echo -e "\e[1;34m┌──── Setting up Unmanic\e[0m"
#    echo -e "\e[1;34m│\e[0m"
#    echo -e "\e[1;34m└─➤\e[0m \e[1;37mExecuting Unmanic setup script...\e[0m"
#    chmod +x $HOME/tmp/public/setup_unmanic.sh
#    $HOME/tmp/public/setup_unmanic.sh
#    echo -e "\e[1;32m└─➤ Unmanic setup completed\e[0m"
#    ;;
#  *)
#    echo -e "\e[1;37m└─➤ Skipping Unmanic installation\e[0m"
#    ;;
#esac
tput cnorm

# Install zsh4humans
#/home/$MYUSER/tmp/public/27_zsh4humans.sh

# Open useful URLs
exit

open https://www.slimjet.com/de/dlpage.php
open https://www.cursor.com/
open https://github.com/Alex313031/Thorium/releases

# Install Kopia backup system
curl -s https://kopia.io/signing-key | $MYSUDO gpg --dearmor -o /etc/apt/keyrings/kopia-keyring.gpg
echo "deb [signed-by=/etc/apt/keyrings/kopia-keyring.gpg] http://packages.kopia.io/apt/ stable main" | $MYSUDO tee /etc/apt/sources.list.d/kopia.list
$MYSUDO apt update
$MYSUDO apt install -y kopia kopia-ui

# Additional GitHub setup
$MYSUDO apt install -y git gh
bws run -- git config --global user.email "$MYEMAIL"
bws run -- git config --global user.name "$GITHUB_USERNAME"
gh auth login

# Clone startsh repo
cd $HOME
gh repo clone startsh

# Setup SSH and handle downloads
[[ ! -d $HOME/.ssh ]] && mkdir $HOME/.ssh
chmod +x $HOME/Downloads/*.AppImage
$MYSUDO apt update 
$MYSUDO apt install $HOME/Downloads/*.deb
/usr/bin/flashpeak-slimjet

# Setup bws
chmod +x $HOME/startsh/script_runner/shs/bws.sh
$HOME/startsh/script_runner/shs/bws.sh

# Configure chezmoi encryption
mkdir -p $HOME/.config/chezmoi
cat > ~/.config/chezmoi/chezmoi.toml <<EOF
encryption = "age"
[age]
    identity = "~/.config/chezmoi/key.txt"
    recipient = "age1j7akucmjyh0w82s20v0f9uut053x8gv6ahlg776wwalskjjycydszgme69"
EOF

# Initialize chezmoi with dotfiles
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply $GITHUB_USERNAME

# Install DeltaChat
$MYSUDO apt install -y snap
$MYSUDO snap install deltachat-desktop
$MYSUDO snap connect deltachat-desktop:camera

# Install zsh4humans
echothis "Installing zsh4humans"
if command -v curl >/dev/null 2>&1; then
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/romkatv/zsh4humans/v5/install)"
else
  sh -c "$(wget -O- https://raw.githubusercontent.com/romkatv/zsh4humans/v5/install)"
fi

# Setup GitHub CLI and git config
echothis "Installing GitHub CLI"
$MYSUDO apt install -y gh git
git config --global user.email "$MYEMAIL"
git config --global user.name "$GITHUB_USERNAME"

# Install Tailscale VPN
if tailscale status >/dev/null 2>&1; then
    echo -e "\e[1;34m┌──── Tailscale Status\e[0m"
    echo -e "\e[1;34m│\e[0m"
    echo -e "\e[1;32m└─➤ Tailscale is already configured\e[0m"
else
    echo -e "\e[1;34m┌──── Installing Tailscale\e[0m"
    echo -e "\e[1;34m│\e[0m"
    echo -e "\e[1;34m└─➤\e[0m \e[1;37mSetting up Tailscale...\e[0m"
    curl -fsSL https://tailscale.com/install.sh | sh && $MYSUDO tailscale up --ssh --accept-routes
fi

# Install Atuin shell history
curl --proto '=https' --tlsv1.2 -LsSf https://setup.atuin.sh | sh

# Install Homebrew and packages
brew_install() {
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  export PATH="/home/linuxbrew/.linuxbrew/bin:$PATH"
  $MYSUDO apt-get install -y build-essential
  brew install gcc
  echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> $MYHOME/.zshrc
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
  exec zsh
}

echothis "Installing Homebrew"
which brew > /dev/null || brew_install

# Install Homebrew packages
echothis "Installing Homebrew packages"
brew install gum pueue

# Install Docker
echothis "Installing Docker"
for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do 
  $MYSUDO apt-get remove $pkg
done

# Add Docker's official GPG key
$MYSUDO apt-get update
$MYSUDO apt-get install -y ca-certificates curl
$MYSUDO install -m 0755 -d /etc/apt/keyrings
$MYSUDO curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
$MYSUDO chmod a+r /etc/apt/keyrings/docker.asc

# Add Docker repository
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  $MYSUDO tee /etc/apt/sources.list.d/docker.list > /dev/null

$MYSUDO apt-get update
$MYSUDO apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
$MYSUDO docker run hello-world

# Setup NFS mounts
exit
$MYSUDO apt install -y nfs-common

echothis "NFS Setup"
read -p "snas 192.168. >> " IP0
IP="192.168.$IP0"

mkdir -p $MYHOME/tmp/startsh_snas
$MYSUDO mount -t nfs $IP:/volume2/startsh_snas $MYHOME/tmp/startsh_snas

if [[ -f $MYHOME/tmp/startsh_snas/env ]]; then
  echothis "Successfully mounted"
  sleep 3
else
  echothis "Mount failed, trying SSHFS"
  sleep 3

  $MYSUDO apt install -y sshfs
  [[ ! -f ~/.ssh/id_rsa ]] && ssh-keygen
  ssh-copy-id $MYUSERNAME@$IP
  sshfs 192.168.11.5/volume2/startsh $MYHOME/tmp/startsh_snas
  
  if [[ -f $MYHOME/tmp/startsh_snas/env ]]; then
    echothis "Successfully mounted via SSHFS"
    sleep 3
  else
    echothis "Mount failed"
    sleep 3
    exit
  fi
fi

source $MYHOME/tmp/startsh_snas/env

# Setup SSH keys and BWS
mkdir -p $HOME/.ssh
if [[ ! -f $HOME/.ssh/bws.dat ]]; then
  cp $MYHOME/tmp/startsh_snas/bws.dat.cpt $HOME/.ssh/
  ccrypt -d $MYHOME/.ssh/bws.dat.cpt
fi

# Clone and run additional setup scripts
mkdir -p $HOME/tmp
cd $HOME/tmp

echothis "Cloning startsh repository"
git clone https://git.yyps.de/abraxas678/startsh.git

echo "Executing start2.sh"
chmod +x $HOME/tmp/startsh/start2.sh
$HOME/tmp/startsh/start2.sh

echo "Setup complete"

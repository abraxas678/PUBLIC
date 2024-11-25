#!/bin/bash
clear
echo -e "\e[1;34m┌──── Public Start.sh v0.34\e[0m"
echo -e "\e[1;34m│\e[0m"
echo -e "\e[1;34m│ 🚀 This script will:\e[0m"
echo -e "\e[1;32m│ 1. Set up user permissions and sudo access\e[0m"
echo -e "\e[1;32m│ 2. Install essential tools (curl, unzip, xsel)\e[0m"
echo -e "\e[1;32m│ 3. Install and configure Kopia backup system\e[0m"
echo -e "\e[1;32m│ 4. Set up Git and GitHub authentication\e[0m"
echo -e "\e[1;32m│ 5. Install development tools (zsh4humans, chezmoi)\e[0m"
echo -e "\e[1;32m│ 6. Configure network tools (Tailscale, Docker)\e[0m"
echo -e "\e[1;32m│ 7. Set up Homebrew and additional utilities\e[0m"
echo -e "\e[1;32m│ 8. Configure NFS/SSHFS mounts\e[0m"
echo -e "\e[1;32m│ 9. Set up SSH and encryption keys\e[0m"
echo -e "\e[1;32m│ 10. Install Unmanic (optional)\e[0m"
echo -e "\e[1;32m│ 11. Configure Delta Chat\e[0m"
echo -e "\e[1;32m│ 12. Set up Atuin shell history\e[0m"
echo -e "\e[1;34m└─➤\e[0m \e[1;37mPress any key to continue...\e[0m"
read -n 1 -s

echothis() {
  echo
  echo -e "\e[1;34m--$@\e[0m"
}
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

export PATH="$HOME/bin:$PATH"
read -p "GITHUB_USERNAME: " GITHUB_USERNAME
read -p "LOCAL_USER: " MYUSERNAME
MYEMAIL="abraxas678@gmail.com"
TAILSCALE_INSTALL="1dee0b6b-63d1-45b3-887e-b23100e3f9dc"

if [[ $USER != "$MYUSERNAME" ]]; then
  echothis "User setup"
  sudo apt install -y sudo
  CHECKUSER=$MYUSERNAME
if [[ $USER == *"root"* ]]; then
  su $CHECKUSER
  adduser $CHECKUSER
  usermod -aG sudo $CHECKUSER
  su $CHECKUSER
  exit
else
  su $CHECKUSER
  sudo adduser $CHECKUSER
  sudo usermod -aG sudo $CHECKUSER
  su $CHECKUSER
exit
fi
fi

sudo apt update
command xsel >/dev/null 2>&1; [[ $? != 0 ]] && sudo apt install xsel -y
wget https://raw.githubusercontent.com/abraxas678/public/refs/heads/master/pop.sh
chmod +x pop.sh
./pop.sh "sudo visudo" &
echo; echothis "sudo visudo:"
SUDOERS_FILE="/etc/sudoers"
NOPASSWD_LINE="$MYUSERNAME ALL=(ALL) NOPASSWD: ALL"

# Check if the line already exists in sudoers
if sudo grep -q "^$NOPASSWD_LINE" "$SUDOERS_FILE"; then
    echo -e "\e[1;32m└─➤ Sudo permissions already configured\e[0m"
else
    ./pop.sh "sudo visudo" &
    echo -e "\e[1;34m│ Adding sudo permissions for $MYUSERNAME\e[0m"
    echo " add:       $NOPASSWD_LINE"
    echo "$NOPASSWD_LINE" | xsel -b
    echo
    read -p "Press any key after editing sudoers" -n 1
fi

sudo apt update
sudo apt upgrade -y
sudo apt install -y curl unzip age ccrypt git gh



bws run -- git config --global user.email "$MYEMAIL"
bws run -- git config --global user.name "$GITHUB_USERNAME"

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

tput civis
CURRENT_HOSTNAME=$(hostname)
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
    sudo hostnamectl set-hostname "$NEW_HOSTNAME"
    # Update /etc/hosts file
    sudo sed -i "s/127.0.1.1.*/127.0.1.1\t$NEW_HOSTNAME/g" /etc/hosts
    echo -e "\e[1;32m└─➤ Hostname updated successfully\e[0m"
    ;;
  *)
    echo -e "\e[1;37m└─➤ Keeping current hostname\e[0m"
    ;;
esac
tput cnorm

tput civis
echo -e "\e[1;34m┌──── Installing and Configuring Chezmoi\e[0m"
echo -e "\e[1;34m│\e[0m"
echo -e "\e[1;34m└─➤\e[0m \e[1;37mUpdating system and installing chezmoi...\e[0m"
sudo apt update && sudo apt upgrade -y && sudo apt install snapd -y
sudo snap install chezmoi  --classic

gh auth status &>/dev/null
if [ $? -ne 0 ]; then
    echo -e "\e[1;34m┌──── GitHub Authentication\e[0m"
    echo -e "\e[1;34m│\e[0m"
    echo -e "\e[1;34m└─➤\e[0m \e[1;37mLogging in to GitHub...\e[0m"
    gh auth login
else
    echo -e "\e[1;34m└─➤\e[0m \e[1;37mGitHub authentication already configured\e[0m"
fi

mkdir -p $HOME/tmp
cd $HOME/tmp
if [ ! -d "public" ]; then
  gh repo clone public
else
  cd public
  git pull
fi
 
command bws >/dev/null 2>&1; [[ $? != 0 ]] && /home/abrax/tmp/public/bws.sh
mkdir -p /home/$MYUSERNAME/.config/chezmoi
cp chezmoi.toml.cpt /home/$MYUSERNAME/.config/chezmoi
cd /home/$MYUSERNAME/.config/chezmoi
ccrypt --decrypt chezmoi.toml.cpt

echo -e "\e[1;34m┌──── Initializing Chezmoi\e[0m"
echo -e "\e[1;34m│\e[0m"
echo -e "\e[1;34m└─➤\e[0m \e[1;37mCloning dotfiles from GitHub...\e[0m"
chezmoi init https://github.com/$GITHUB_USERNAME/dotfiles.git

echo -e "\e[1;34m┌──── Checking Changes\e[0m"
echo -e "\e[1;34m│\e[0m"
echo -e "\e[1;34m└─➤\e[0m \e[1;37mShowing diff of changes to be applied:\e[0m"
#chezmoi diff
echo -e "\e[1;34m┌──── Applying Changes\e[0m"
echo -e "\e[1;34m│\e[0m"
echo -e "\e[1;34m└─➤\e[0m \e[1;37mExecuting 'chezmoi update' to apply dotfile changes...\e[0m"
chezmoi update
echo -e "\e[1;32m└─➤ Changes applied successfully\e[0m"
tput cnorm

tput civis
echo -e "\e[1;34m┌──── Unmanic Installation\e[0m"
echo -e "\e[1;34m│\e[0m"
echo -e "\e[1;34m└─➤\e[0m \e[1;37mWould you like to install Unmanic? (y/n):\e[0m"
read -n 1 INSTALL_UNMANIC
echo

case $INSTALL_UNMANIC in
  [Yy]*)
    echo -e "\e[1;34m┌──── Setting up Unmanic\e[0m"
    echo -e "\e[1;34m│\e[0m"
    echo -e "\e[1;34m└─➤\e[0m \e[1;37mExecuting Unmanic setup script...\e[0m"
    chmod +x $HOME/tmp/public/setup_unmanic.sh
    $HOME/tmp/public/setup_unmanic.sh
    echo -e "\e[1;32m└─➤ Unmanic setup completed\e[0m"
    ;;
  *)
    echo -e "\e[1;37m└─➤ Skipping Unmanic installation\e[0m"
    ;;
esac
tput cnorm

exit
open https://www.slimjet.com/de/dlpage.php
open https://www.cursor.com/
open https://github.com/Alex313031/Thorium/releases


## KOPIA
curl -s https://kopia.io/signing-key | sudo gpg --dearmor -o /etc/apt/keyrings/kopia-keyring.gpg
echo "deb [signed-by=/etc/apt/keyrings/kopia-keyring.gpg] http://packages.kopia.io/apt/ stable main" | sudo tee /etc/apt/sources.list.d/kopia.list

sudo apt update
sudo apt install kopia
sudo apt install kopia-ui

sudo apt install git gh -y

bws run -- git config --global user.email "$MYEMAIL"
bws run -- git config --global user.name "$GITHUB_USERNAME"


gh auth login

cd $HOME
gh repo clone startsh

[[ ! -d $HOME/.ssh ]] && mkdir $HOME/.ssh

chmod +x $HOME/Downloads/*.AppImage
sudo apt update 
sudo apt install $HOME/Downloads/*.deb
/usr/bin/flashpeak-slimjet

chmod +x $HOME/startsh/script_runner/shs/bws.sh
$HOME/startsh/script_runner/shs/bws.sh

mkdir -p $HOME/.config/chezmoi
cat > ~/.config/chezmoi/chezmoi.toml <<EOF
encryption = "age"
[age]
    identity = "~/.config/chezmoi/key.txt"
    recipient = "age1j7akucmjyh0w82s20v0f9uut053x8gv6ahlg776wwalskjjycydszgme69"
EOF

sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply $GITHUB_USERNAME

sudo apt install -y snap
sudo snap install deltachat-desktop
sudo snap connect deltachat-desktop:camera 

echothis "zsh4humans"
if command -v curl >/dev/null 2>&1; then
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/romkatv/zsh4humans/v5/install)"
else
  sh -c "$(wget -O- https://raw.githubusercontent.com/romkatv/zsh4humans/v5/install)"
fi


echothis "install github gh"
sudo apt install gh git -y
git config --global user.email "$MYEMAIL"
git config --global user.name "$GITHUB_USERNAME"
#echothis "apt install python3-pip pix"
#sudo apt install python3-pip pipx -y
#pipx ensurepath
#echothis "install ansible (pipx)"
#pipx install --include-deps ansible

# Check if Tailscale is already configured
if tailscale status >/dev/null 2>&1; then
    echo -e "\e[1;34m┌──── Tailscale Status\e[0m"
    echo -e "\e[1;34m│\e[0m"
    echo -e "\e[1;32m└─➤ Tailscale is already configured\e[0m"
else
    echo -e "\e[1;34m┌──── Installing Tailscale\e[0m"
    echo -e "\e[1;34m│\e[0m"
    echo -e "\e[1;34m└─➤\e[0m \e[1;37mSetting up Tailscale...\e[0m"
    curl -fsSL https://tailscale.com/install.sh | sh && sudo tailscale up --ssh --accept-routes
fi

curl --proto '=https' --tlsv1.2 -LsSf https://setup.atuin.sh | sh

#10. Homebrew Setup and Hombrew app install

# Install Homebrew and its dependencies
brew_install() {
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  export PATH="/home/linuxbrew/.linuxbrew/bin:$PATH"
  sudo apt-get install -y build-essential
  brew install gcc
  echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> $MYHOME/.zshrc
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
  exec zsh
  export ANS=n
}

echothis "install brew"
# Install Homebrew if not already installed
which brew > /dev/null
if [[ $? != 0 ]]; then
  echo -e "${YELLOW}INSTALL: Homebrew${RESET}"
  countdown 1
  brew_install
fi

echothis gum
brew install gum

echothis pueue
brew install pueue

echothis docker
for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do sudo apt-get remove $pkg; done
# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update

sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y

sudo docker run hello-world


exit
sudo apt install nfs-common -y
echo
echothis "USER INPUT:"
read -p "snas 192.168. >> " IP0
IP="192.168.$IP0"

mkdir -p $MYHOME/tmp/startsh_snas; sudo mount -t nfs $IP:/volume2/startsh_snas $MYHOME/tmp/startsh_snas

if [[ -f $MYHOME/tmp/startsh_snas/env ]]; then
  echothis "sucessfully mounted" 
  sleep 3
else
  echothis "not mounted" 
  sleep 3

  sudo apt install -y sshfs
  [[ ! -f ~/.ssh/id_rsa ]] && ssh-keygen
  ssh-copy-id $MYUSERNAME@$IP
  sshfs 192.168.11.5/volume2/startsh $MYHOME/tmp/startsh_snas
  if [[ -f $MYHOME/tmp/startsh_snas/env ]]; then
    echothis "sucessfully mounted" 
    sleep 3
  else
    echothis "not mounted" 
    sleep 3
    exit
  fi
fi

sleep 1
echo

source $MYHOME/tmp/startsh_snas/env

echo

isinstalled ccrypt

echothis "long num 2x"

mkdir $HOME/.ssh -p
if [[ ! -f $HOME/.ssh/bws.dat ]]; then
  cp $MYHOME/tmp/startsh_snas/bws.dat.cpt $HOME/.ssh/
  ccrypt -d $MYHOME/.ssh/bws.dat.cpt
fi

isinstalled git
isinstalled gh

git config --global user.email "$MYEMAIL"
git config --global user.name "$MYUSERNAME"

# Check if already logged in to GitHub
#if ! gh auth status &>/dev/null; then
#    echothis "Logging in to GitHub..."
#    gh auth login
#else
#    echothis "Already logged in to GitHub"
#fi

mkdir $HOME/tmp -p
cd $HOME/tmp

echothis "cloning startsh"
#gh repo clone startsh
git clone https://git.yyps.de/abraxas678/startsh.git

echo
echo "startsh/start2.sh"
echo
chmod +x $HOME/tmp/startsh/start2.sh
echo
echo executing start2.sh
sleep 3
exit

$HOME/tmp/startsh/start2.sh

echo DONE

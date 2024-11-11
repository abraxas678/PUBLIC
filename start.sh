#!/bin/bash
MYEMAIL=abraxas678@gmail.com
MYUSERNAME="abraxas678"
clear
echo -e "\e[1;34m┌─ public Start.sh v0.18\e[0m"
sleep 3
export GITHUB_USERNAME="abraxas678"

echothis() {
  echo
  echo -e "\e[1;34m--$@\e[0m"
}

if [[ $USER != "abrax" ]]; then
echothis "User setup"
sudo apt install -y sudo
CHECKUSER=abrax
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

cat > ~/.config/chezmoi/chezmoi.toml <<EOF
encryption = "age"
[age]
    identity = "~/.config/chezmoi/key.txt"
    recipient = "age1j7akucmjyh0w82s20v0f9uut053x8gv6ahlg776wwalskjjycydszgme69"
EOF

echothis "apt update && upgrade"
#ts=$(date +%s)

#MYHOME=$HOME
#MYPWD=$PWD
#echo
#echothis MYHOME $MYHOME
#echothis MYPWD $MYPWD
#sleep 3
#echo

sudo apt update && sudo apt upgrade -y

echothis "zsh4humans"
if command -v curl >/dev/null 2>&1; then
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/romkatv/zsh4humans/v5/install)"
else
  sh -c "$(wget -O- https://raw.githubusercontent.com/romkatv/zsh4humans/v5/install)"
fi


echothis "install github gh"
sudo apt install gh git -y
git config --global user.email "$MYEMAIL"
git config --global user.name "$MYUSERNAME"
#echothis "apt install python3-pip pix"
#sudo apt install python3-pip pipx -y
#pipx ensurepath
#echothis "install ansible (pipx)"
#pipx install --include-deps ansible
echothis "install chezmoi"
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply $GITHUB_USERNAME

curl -fsSL https://tailscale.com/install.sh | sh && sudo tailscale up --ssh --accept-routes

curl --proto '=https' --tlsv1.2 -LsSf https://setup.atuin.sh | sh

#!/bin/bash
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

# Install utilities using Homebrew

while IFS= read -r line; do
  [[ $line != "#"* ]] && brew install $line
done < 	brew_all_multi.txt

echothis gum
brew install gum

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
  ssh-copy-id $abrax@$IP
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

root@test:~# cat start.sh 
#!/bin/bash
clear
echo v0.1
echo 67 | grep -E "^[0-9]+$"sleep 1
clear

header1() {
  tput cup $x 0; tput ed
  export v1="$@"
  echo -e "\e[1;38;5;34m╭─ \e[1;38;5;39m$@\e[0m"
  echo -e "\e[1;38;5;34m╰─ \e[2;38;5;245m[$(date +%H:%M:%S)]\e[0m"
  echo
}
header2() {
  RES=$?
  sleep 2
  x=$((x+1))
  [[ $RES = 0 ]] && tput cup $x 3; tput ed
  [[ $RES = 0 ]] && echo -e "\e[1;38;5;46m󰄬 [COMPLETED]\e[0m" ||  echo -e "\e[1;38;5;196m󰅙 [FAILED]\e[0m"
  x=$((x+2))
}

install_docker() {

# Exit immediately if a command exits with a non-zero status.
set -e

echo ">>> Starting Docker installation for Debian/Ubuntu-based systems..."

# 1. Check if Docker is already installed
if command -v docker &> /dev/null; then
    echo ">>> Docker appears to be already installed. Version:"
    docker --version
    echo ">>> Exiting installation script."
    exit 0
fi

# 2. Update package index and install prerequisites
echo ">>> Updating package list and installing prerequisites..."
apt-get update
apt-get install -y \
    git \
    gh \
    ca-certificates \
    curl \
    gnupg

# 3. Add Docker's official GPG key
echo ">>> Adding Docker GPG key..."
install -m 0755 -d /etc/apt/keyrings
# Check if the key file already exists and remove it to avoid potential issues
if [ -f /etc/apt/keyrings/docker.gpg ]; then
    echo ">>> Removing existing docker.gpg key..."
    rm -f /etc/apt/keyrings/docker.gpg
fi
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
chmod a+r /etc/apt/keyrings/docker.gpg

# 4. Set up the Docker repository
echo ">>> Setting up Docker repository..."
# Detect architecture and OS version codename
ARCH=$(dpkg --print-architecture)
if [ -f /etc/os-release ]; then
    # shellcheck source=/dev/null
    . /etc/os-release
    VERSION_CODENAME=${VERSION_CODENAME:-$(lsb_release -cs)} # Fallback if not in /etc/os-release
else
    VERSION_CODENAME=$(lsb_release -cs)
fi

if [ -z "$VERSION_CODENAME" ]; then
    echo ">>> ERROR: Could not determine OS version codename."
    exit 1
fi

echo \
  "deb [arch=${ARCH} signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  ${VERSION_CODENAME} stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

# 5. Install Docker Engine
echo ">>> Installing Docker Engine..."
apt-get update
apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# 6. Verify installation
echo ">>> Verifying installation by running hello-world container..."
if docker run hello-world; then
    echo ">>> Docker installed successfully!"
else
    echo ">>> ERROR: Docker hello-world container failed to run. Installation might be incomplete."
    exit 1
fi

# 7. Optional: Add current user to the docker group
#    This avoids needing sudo for every docker command.
#    Requires logout/login or `newgrp docker` to take effect.
if [ -n "$SUDO_USER" ]; then
    echo ">>> Adding user '$SUDO_USER' to the docker group..."
    usermod -aG docker "$SUDO_USER"
    echo ">>> NOTE: You need to log out and log back in for the group changes to take effect for user '$SUDO_USER'."
elif [ "$(id -u)" -eq 0 ] && [ -n "$USER" ] && [ "$USER" != "root" ]; then
     # Handle case where script is run directly as root, but we might want to add the invoking user
     echo ">>> Adding user '$USER' to the docker group..."
     usermod -aG docker "$USER"
     echo ">>> NOTE: You need to log out and log back in for the group changes to take effect for user '$USER'."
else
    echo ">>> Could not determine non-root user to add to the docker group. Run 'sudo usermod -aG docker \$USER' manually if desired."
fi


echo ">>> Docker installation script finished."
}

# Determine if sudo is needed for commands
if [[ "$(whoami)" == "root" ]]; then
    MYSUDO=""
else
    MYSUDO="sudo"
fi

x=1
header1 "ping google.com"
ping -c 2 google.com
RES=$?
if [[ $RES != 0 ]]; then
  $MYSUDO echo "nameserver 1.1.1.1" >>/etc/resolv.conf
  cat /etc/resolv.conf
  ping -c 2 google.com
  header2
fi
echo
sleep 3

header1 "apt update"
$MYSUDO apt update
header2
header1 "apt install curl"
$MYSUDO apt install -y curl wget nano
header2
header1 "apt upgrade -y"
$MYSUDO apt upgrade -y
header2

#header1 "install docker"
#install_docker
#header2

#header1 rslsync
#./rslsync
#header2

#re
#open http://

header1 "ssh-agent"
ssh-agent
header2

header1 "ssh-add"
ssh-add
header2

header1 "create ram folder"
mkdir $HOME/tmp/ram -p 
$MYSUDO mount -t tmpfs -o size=100M tmpfs $HOME/tmp/ram
header2

header1 wormhole
sudo apt update && sudo apt install wormhole -y
header2

if [[ 1 = 2 ]]; then
header1 "local pc"
echo 
header1 "continue on local pc: start_local_pc.sh"
echo
read -p B me
cd ~/.ssh
sudo mv transfer transfer.old
sudo mv id_ed25519  id_ed25519.bak
sudo mv id_ed25519.pub  id_ed25519.pub.bak
echo
curl -s https://pc.xxxyzzz.xyz/wh
echo
sleep 2
curl -s https://pc.xxxyzzz.xyz/wh >wh
cd ~/.ssh
source wh
sudo cp ~/.ssh/transfer/* ~/.ssh/
header2
fi

header1 "git clone"
#mkdir $HOME/tmp/ -p
cd $HOME/tmp/ram/
GIT_SSH_COMMAND='ssh -p 222' git clone git@192.168.0.144:abraxas678/envs.git
header2

#header1 "snas check"
#cd $HOME/tmp/ram
#read -p "SNAS IP: >> " SNASIP
#curl -L https://$SNASIP:5443/envs -O --insecure
#header2

header1 "source envs"
source $HOME/tmp/ram/envs/envs
header2

header1 "chezmoi.tar"
#curl -L https://$SNASIP:5443/chezmoi.tar -O --insecure
mkdir -p $HOME/.config/chezmoi/
$MYSUDO mv $HOME/tmp/ram/envs/chezmoi_config.tar.gz $HOME/.config/chezmoi/
cd $HOME/.config/chezmoi/
$MYSUDO tar xf chezmoi_config.tar.gz
header2

header1 "move .config/chezmoi"
 $MYSUDO mv $HOME/.config/chezmoi/chezmoi_config/* $HOME/.config/chezmoi/
header2

header1 "install chezmoi"
echo "GITHUB_USERNAME: $GITHUB_USERNAME"
sleep 2
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --ssh --apply $GITHUB_USERNAME
header2

$MYSUDO mv $HOME/.config/chezmoi/bin/chezmoi /usr/bin/

header1 "reset chezmoi"
chezmoi state delete-bucket --bucket=entryState
#To clear the state of run_once_ scripts, run:
chezmoi state delete-bucket --bucket=scriptState
header2

chezmoi init --apply --ssh abraxas678
cd  ~/.local/share/chezmoi
git remote add origin git@github.com:abraxas678/dotfiles.git
chezmoi update -k







echo

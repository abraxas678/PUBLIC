#!/bin/bash
clear
MYHOME=$HOME
echo MYHOME=$MYHOME
sleep 1
cd $HOME
echo version: NEWv14

echo; echo "cd $MYHOME/bin/ 
up sync.sh 
up down.sh 
up sync.txt 
up header.sh
up header2.sh
up ~/.config/rclone/rclone.conf"
echo

#read -t 10 me

GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
PURPLE='\033[0;35m'
ORANGE='\033[0;33m'
GREY='\033[0;37m'
LIGHT_BLUE='\033[1;34m'
RESET='\033[0m'
RC='\033[0m'

CUR_REL=$(curl -L start.yyps.de | grep "echo version:" | sed 's/echo version: NEWv//')
NEW_REL=$((CUR_REL+1))
echo CUR_REL: $CUR_REL
echo NEW_REL: $NEW_REL

installme() {
  which $@
  if [[ $? != "0" ]]; then
    echo
    echo -e "\e[33mINSTALL: $1\e[0m"  
    countdown 1
    sudo apt install $1 -y
  fi
}

brew_install() {
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    export PATH="/home/linuxbrew/.linuxbrew/bin:$PATH"
    sudo apt-get install build-essential -y
    brew install gcc
   (echo; echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"') >> $MYHOME/.zshrc
   eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
   exec zsh
   export ANS=n
}
release_wait() {
  x=1
  while [[ $x = 1 ]]; do
    echo WAITING FOR RELEASE
    sleep 5
    CUR_REL=$(curl -L start.yyps.de | grep "echo version:" | sed 's/echo version: NEWv//')
    echo $CUR_REL $NEW_REL
    [[ $CUR_REL = $NEW_REL ]] && x=0
  done
    echo realease ready
    exit
}
VERS="n"
read -t 5 -n 1 -p "\[W]AIT FOR NEXT RELEASE - v$NEW_REL? >>" VERS
[[ $VERS = "w" ]] && release_wait
echo

check_dns() {
    echo check_dns
    cd $HOME
    sudo ping  -c 1 google.com >/dev/null && echo "Online" || echo "Offline"
    sudo ping  -c 1 google.com >/dev/null && ONL=1 || ONL=0
    if [[ $ONL = "0" ]]; then
      CHECK=$(cat /etc/resolv.conf)
      if [[ $CHECK != *"8.8.8.8"* ]] ; then
    echo donix
    #    echo nameserver 8.8.8.8 >~/resolv.conf
    #    cat /etc/resolv.conf>>~/resolv.conf
    #    sudo mv ~/resolv.conf /etc/
      fi
    sudo ping  -c 1 google.com >/dev/null && echo "Online" || echo "Offline"
    fi
}

header1(){
  echo -e "\e[33m$@\e[0m"  
}

header2(){
  TEXT=$(echo "$@" | tr '[:lower:]' '[:upper:]')
  echo -e "\e[94m$TEXT\e[0m"
}

countdown() {
    if [ -z "$1" ]; then
        echo "No argument provided. Please provide a number to count down from."
        exit 1
    fi

    tput civis
    for ((i=$1; i>0; i--)); do
        if (( i > $1*66/100 )); then
            echo -ne "\033[0;32m$i\033[0m\r"
        elif (( i > $1*33/100 )); then
            echo -ne "\033[0;33m$i\033[0m\r"
        else
            echo -ne "\033[0;31m$i\033[0m\r"
        fi
        sleep 1
        echo -ne "\033[0K"
    done
    echo -e "\033[0m"
    tput cnorm
}

TASK() {
  echo
  header1 $@
  countdown 1
}

check_dns

if [[ "$(hostname)" = "lenovo" ]]; then
  header2 change machine name
  echo hostname=lenovo
  cd $HOME
  curl -sL machine.yyps.de >machine.sh
  chmod +x machine.sh
  ./machine.sh
fi

mkdir ~/tmp -p
MYPWD=$PWD
cd $HOME/tmp


#echo user1
TASK "CHECK: USER = abrax? "
# Check if user is not abrax, if not then switch to abrax
if [[ $USER != *"abrax"* ]]; then
#if [[ $USER != *"abra"* ]]; then
  apt install -y sudo
  if [[ $USER = *"root"* ]]; then
    su abrax
    adduser abrax
    usermod -aG sudo abrax
    su abrax
    exit
  else
    su abrax
    sudo adduser abrax
    sudo usermod -aG sudo abrax
    su abrax
    exit
  fi
fi
#fi

TASK "check last update time"
ts=$(date +%s)
if [[ -f ~/last_apt_update.txt ]]; then
  DIFF=$(($ts-$(cat ~/last_apt_update.txt)))
  if [[ $DIFF -gt "6000" ]]; then
    sudo apt update && sudo apt upgrade -y
  fi
else
  sudo apt update && sudo apt upgrade -y
fi
echo $ts >~/last_apt_update.txt

header2 "install dependencies using apt"
countdown 1
installme curl
installme git
installme gh
git config --global user.email "abraxas678@gmail.com"
git config --global user.name "abraxas678"

gh repo list
if [[ $? = 0 ]]; then
  echo "gh logged in"
  sleep 1
else
  gh status
  gh auth refresh -h github.com -s admin:public_key
  gh ssh-key add ./id_ed25519.pub
fi
echo
cd
if [[ ! -d $MYHOME/bin ]]; then
echo gh repo clone abraxas678/bin
gh repo clone abraxas678/bin
echo
sleep 1
cd
gh repo clone abraxas678/.config
echo
sleep 1
fi

chmod +x ~/bin/*

installme davfs2
installme unzip
installme wget
installme zoxide
#installme nfs-common
#installme rclone
installme keepassxc
echo
echo rclone beta
countdown 1
sudo -v ; curl https://rclone.org/install.sh | sudo bash -s beta
echo
#installme unison
installme python3-pip
installme pipx
pipx install rich-cli
pipx install shell-gpt
pipx install apprise
#installme zsh

#oh_my_zsh() {
#    TASK "oh-my-zsh"
#    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
#    TASK ".p10k"
#    git clone --depth=1 https://gitee.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
#}


RES=$(which tailscale)
which tailscale >/dev/null 2>&1
if [[ $? != "0" ]]; then
  echo install tailscale
  sleep 1
  #curl -L https://tailscale.com/install.sh 
  #curl -s 5 -fsSL https://tailscale.com/install.sh | sh
  curl -L https://tailscale.com/install.sh | sh
fi
sudo tailscale up --ssh --accept-routes
tailscale status
countdown 2

tailscale status
if [[ $? != "0" ]]; then
  sudo tailscaled --tun=userspace-networking --socks5-server=localhost:1055 --outbound-http-proxy-listen=localhost:1055 &
  countdown 2
  sudo tailscale up --ssh --accept-routes
fi
echo
check_dns
#export BH_URL="http://$(tailscale status | grep hetzner  | awk '{print $1}'):8081"
export BH_URL="http://100.98.141.82:8081"
echo; echo BH_URL: $BH_URL
echo
sleep 1
if [[ $(cat ~/.bashrc) != *"BH_URL"* ]]; then
  echo export BH_URL="http://$( tailscale status | grep hetzner  | awk '{print $1}'):8081" >>~/.bashrc
fi
if [[ $(cat ~/.zshrc) != *"BH_URL"* ]]; then
  echo export BH_URL="http://$( tailscale status | grep hetzner  | awk '{print $1}'):8081" >>~/.zshrc
fi

mybashhub() {
  mybh="y"
  which bh >/dev/null 2>&1
  if [[ $? != "0" ]]; then
    read -t 10 -n 1 -p "BASHHUB? >> " mybh
    if [[ $mybh = "y" ]]; then
      TASK bashhub 
      curl -OL https://bashhub.com/setup && $SHELL setup
    fi
  fi
}
mybashhub

#mkdir -p $HOME/.config/rclone
##cd $HOME/.config/rclone
#curl -Ls hetzner:2586/rclone.conf -O
read -p "RC PW >> " RCPW
clear
export RCLONE_CONFIG_PASS="$RCPW"
#rclone copy sb2:sync.sh/bin/sync.sh $HOME/bin
##rclone copy sb2:sync.sh/bin/sync.txt $HOME/bin
#rclone copy sb2:sync.sh/bin/down.sh $HOME/bin
#rclone copy sb2:sync.sh/bin/up.sh $HOME/bin
#rclone copy sb2:sync.sh/bin/header.sh $HOME/bin
chmod +x $HOME/bin/*.sh

echo; echo sync.sh
countdown 1
$MYHOME/bin/sync.sh
countdown 1

export ANS=n
export PATH="/home/linuxbrew/.linuxbrew/bin/brew:$PATH"
echo; read -n 1 -p "install BREW? (y/n) >> " ANS
[[ $ANS = "y" ]] && echo brew #brew

echo eza
countdown 1
brew install eza

mount_nc() {
  echo
  header2 MOUNTING NEXTCLOUD
  echo
  if [[ ! -f /home/mnt/nc/MOUNT_CHECK ]]; then
    if [[ ! -d /home/mnt/nc ]]; then
      sudo mkdir /home/mnt/nc -p
      sudo chown abrax: -R /home/mnt/nc
    fi 
     sudo mount -t davfs -o exec https://nxt.dmw.zone/remote.php/dav/files/abraxas678 /home/mnt/nc
  fi
}
#mount_nc

mount_folder() {
  mkdir -p $MYHOME/bin
  mkdir -p $MYHOME/.config
  sshfs abrax@192.168.11.162:/var/www/nextcloud/data/abraxas678/files/LINUX/abrax/bin $MYHOME/bin
  sshfs abrax@192.168.11.162:/var/www/nextcloud/data/abraxas678/files/LINUX/abrax/.config $MYHOME/.config
# sudo mount -t davfs -o noexec https://nxt.dmw.zone/remote.php/dav/files/abraxas678 /home/mnt/nc
}
#mount_folder
echo


echo
echo zsh4humans
countdown 1
if command -v curl >/dev/null 2>&1; then
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/romkatv/zsh4humans/v5/install)"
else
  sh -c "$(wget -O- https://raw.githubusercontent.com/romkatv/zsh4humans/v5/install)"
fi




exit


if [[ -f /home/mnt/nc/MOUNT_CHECK ]]; then
  echo Nexcloud /home/mnt/nc sucessfully mounted
fi

ls $MYHOME/bin/MONT_CHECK >/dev/null 2>&1
if [[ $? = "0" ]]; then
  echo Nexcloud bin sucessfully mounted
else
  echo bin bin
fi
if [[ -f $MYHOME/.config/MOUNT_CHECK ]]; then
  echo Nexcloud .config sucessfully mounted
fi
echo



mount_choice() {
    read -p "MOUNT VIA [s]nas OR [n]extcloud? >> " -n 1 MYMOUNT
    echo
    if [[ $MYMOUNT = "s" ]]; then
    SNAS_IP=$(tailscale status | grep snas | awk '{print $1}')
    COUNT=${#SNAS_IP}
    [[ "$COUNT" = "0" ]] && read -p "SNAS-IP: >> " SNAS_IP
    echo
    header2 "SNAS_IP: $SNAS_IP"
    echo
    read -t 1 me
    
    if [[ ! -f /home/mnt/snas/setup/MOUNT_CHECK ]]; then
    # Install ubuntu-desktop and xrdp
    #sudo apt install ubuntu-desktop xrdp -y
    
    # Install Twingate if not already installed
    #if [[ "$(command twingate 2>&1)" = *"command not found"* ]]; then
    #  curl -s https://binaries.twingate.com/client/linux/install.sh | sudo bash
    #fi
    
    # Setup Twingate if not running
    #if [[ $(twingate status) = *"not-running"* ]]; then
    #  sudo twingate setup --headless head.json
    #fi
    
    # Authenticate Twingate if not authenticated
    #if [[ $(twingate resources) = *"Not authenticated"* ]]; then
    #  sudo twingate auth snas
    #fi
    
    # Check Twingate status, if not online then start it
    #if [[ $(twingate status) != *"online"* ]]; then
    #  timeout 10 /usr/bin/twingate-notifier console
    #fi
    echo
    TASK="MOUNT SNAS"
    read -t 1 -p "starting: $TASK" me; echo
    
    # Create directories for SNAS setup
    #sudo mkdir -p /home/mnt/snas/sync
    sudo mkdir -p /home/mnt/snas/setup
    #sudo mkdir -p /home/mnt/snas/downloads2
    
    # Change ownership and permissions if directories are not mounted
    #for dir in sync setup downloads2; do
    for dir in setup; do
    if [[ ! -f /home/mnt/snas/$dir/MOUNT_CHECK ]]; then
    sudo chown $USER: -R /home/mnt/snas/$dir
    sudo chmod 777 /home/mnt/snas/$dir -R
    fi
    done
    echo
    TASK="get mount.sh"
    read -t 1 -p "starting: $TASK" me; echo
    curl -s -L https://raw.githubusercontent.com/abraxas678/public/master/mount.sh -o mount.sh
    echo
    TASK="start mount.sh"
    read -t 1 -p "starting: $TASK" me; echo
    
    source ./mount.sh
    echo
    TASK="mount dirs"
    read -t 1 -p "starting: $TASK" me; echo
    
    # Mount directories if not already mounted
    #for dir in sync setup downloads2; do
    for dir in setup; do
    if [[ ! -f /home/mnt/snas/$dir/MOUNT_CHECK ]]; then
    sudo mount -t nfs -o vers=3 $SNAS_IP:/volume2/$dir /home/mnt/snas/$dir
    sudo mount -t nfs -o vers=3 $SNAS_IP:/volume1/$dir /home/mnt/snas/$dir
    fi
    done
    
    # Change ownership and permissions for setup directory
    #sudo chown $USER: -R /home/mnt/snas/setup
    #sudo chmod 777 /home/mnt/snas/setup -R
    else
    echo DOWNLOAD mount_nextcloud.sh
    sleep 1
    wget https://raw.githubusercontent.com/abraxas678/public/master/mount_nextcloud.sh
    chmod +x mount_nextcloud.sh
    ./mount_nextcloud.sh
    sudo mkdir -p /home/mnt/snas/setup
    sudo chown abrax: -R /home/mnt/snas/setup
    ln -s /home/mnt/nextcloud/EXT_StorageBox/setup /home/mnt/snas/setup
    fi
    
    echo
    TASK="check mount"
    read -t 1 -p "starting: $TASK" me; echo
    fi
    
    # Wait until setup directory is mounted
    while [[ ! -f /home/mnt/snas/setup/MOUNT_CHECK ]]; do
    echo "checking mount"
    sleep 1
    done

    
    mkdir $MYHOME/.config -p
    [[ ! -f $MYHOME/.config/sync.txt ]] && cp /home/mnt/snas/setup/sync.txt $MYHOME/.config/
    mkdir -p $MYHOME/.config/rclone/
    [[ ! -f $MYHOME/.config/rclone/rclone.conf ]] && cp /home/mnt/snas/setup/rclone.conf $MYHOME/.config/rclone/
    [[ ! -f $MYHOME/bin/sync.sh ]] && cp /home/mnt/snas/setup/sync.sh $MYHOME/bin/
    [[ ! -f $MYHOME/bin/age ]] && cp /home/mnt/snas/setup/age $MYHOME/bin/
    echo
    echo chmod +x bin
    
    chmod +x $MYHOME/bin/*
    if [[ ! -f $MYHOME/.config/rclone/rclone.conf ]]; then
    header1 'execute   curl -s -T ~/.config/rclone/rclone.conf "hetzner:2586/rc?t=3m"'
    echo
    read -p BUTTON me
    curl -L hetzner:2586/rc -o ~/.config/rclone/rclone.conf
    COUNT=$(rclone listremotes | wc -l)
    [[ $COUNT > "100" ]] && echo "rclone.conf: OK"
    fi
    
    rclone copy snas:mutagen/.ssh ~/.ssh -P --progress-terminal-title --stats-one-line
    rclone copy snas:mutagen/bin/sync.sh ~/bin/ -P --progress-terminal-title --stats-one-line
    rclone copy snas:mutagen/bin/header.sh ~/bin/ -P --progress-terminal-title --stats-one-line
    rclone copy snas:mutagen/bin/uni.sh ~/bin/ -P --progress-terminal-title --stats-one-line
    rclone copy snas:mutagen/.config/sync.txt ~/.config/ -P --progress-terminal-title --stats-one-line
    sudo chmod +x ~/bin/*
    #sudo apt install -y python3-rich_cli
    #export RCLONE_PASSWORD_COMMAND="ssh abraxas@snas cat /volume2/mutagen/.ssh/rclonepw.sh | bash"
    echo
    header1 sync.sh --skip --force
    $MYHOME/bin/sync.sh --skip --force
}
# Source start2.sh script
#echo
#echo "STARTING START2.SH"
#sleep 1

#source /home/mnt/snas/setup/start2.sh

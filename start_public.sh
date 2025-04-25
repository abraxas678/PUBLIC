root@test:~# cat start.sh 
#!/bin/bash
clear
echo v0.1
sleep 1
clear

header1() {
  tput cup $x 0
  export v1="$@"
  echo -e "\e[1;38;5;34m╭─ \e[1;38;5;39m$@\e[0m"
  echo -e "\e[1;38;5;34m╰─ \e[2;38;5;245m[$(date +%H:%M:%S)]\e[0m"
  echo
}
header2() {
  RES=$?
  sleep 3
  x=$((x+1))
  [[ $RES = 0 ]] && tput cup $x 3; tput ed
  [[ $RES = 0 ]] && echo -e "\e[1;38;5;46m󰄬 [COMPLETED]\e[0m" ||  echo -e "\e[1;38;5;196m󰅙 [FAILED]\e[0m"
  x=$((x+2))
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
fi
echo
sleep 3
header2

header1 "apt update"
$MYSUDO apt update
header2
header1 "apt install curl"
$MYSUDO apt install -y curl wget nano
header2
header1 "apt upgrade -y"
$MYSUDO apt upgrade -y
header2
header1 "create ram folder"
mkdir $HOME/tmp/ram -p 
$MYSUDO mount -t tmpfs -o size=100M tmpfs $HOME/tmp/ram
header2
header1 "snas check"
cd $HOME/tmp/ram
read -p "SNAS IP: >> " SNASIP
curl -L https://$SNASIP:5443/envs -O --insecure
header2

source $HOME/tmp/ram/envs

header1 "chezmoi.tar"
curl -L https://$SNASIP:5443/chezmoi.tar -O --insecure
mkdir -p $HOME/.config/chezmoi/
$MYSUDO mv $HOME/tmp/ram/chezmoi.tar $HOME/.config/chezmoi/
cd $HOME/.config/chezmoi/
$MYSUDO tar xf chezmoi.tar
header2
header1 "move .config/chezmoi"
 $MYSUDO mv $HOME/.config/chezmoi/$HOME/.config/chezmoi/* $HOME/.config/chezmoi/
header2

header1 "install chezmoi"
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --ssh --apply $GITHUB_USERNAME
header2

$MYSUDO mv $HOME/.config/chezmoi/bin/chezmoi /usr/bin/

header1 "reset chezmoi"
chezmoi state delete-bucket --bucket=entryState
#To clear the state of run_once_ scripts, run:
chezmoi state delete-bucket --bucket=scriptState
header2

chezmoi update -k







echo

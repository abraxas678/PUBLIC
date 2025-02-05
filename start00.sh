#! /bin/bash
[[ $(whoami) = "root" ]] && MYSUDO="" || MYSUDO="sudo"
$MYSUDO apt update

command gum -v >/dev/null 2>&1
if [[ $? != 0 ]]; then
  /home/abrax/tmp/public/gum_install.sh
fi





bws run -- git config --global user.email "$MYEMAIL"
bws run -- git config --global user.name "$GITHUB_USERNAME"

if [[ ! -d $HOME/tmp/public ]]; then
  [[ ! -d $HOME/tmp ]] && mkdir -p $HOME/tmp
  cd $HOME/tmp
  git clone https://github.com/abraxas678/public
else
  cd $HOME/tmp/public
  git pull
fi

command bws --version >/dev/null 2>&1;
STAT=$(echo $?)
echo STAT $STAT
sleep 2
if [[ $STAT != 0 ]]; then
  $HOME/tmp/public/bws_install.sh
fi

mkdir -p ~/.ssh
BWS="$(gum input --password --no-show-help --placeholder='enter OTP')"
#read -p "bws.dat: >> " BWS
echo $BWS >~/.ssh/bws.dat
command chezmoi -v >/dev/null 2>&1
STAT="$(echo $?)"
if [[ $STAT != 0 ]]; then
  bws run -- sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply $GITHUB_USERNAME
fi

#41bff4b2-2ccb-42ba-b33a-b27a00ba0f50

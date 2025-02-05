##! /bin/bash

[[ $(whoami) = "root" ]] && MYSUDO="" || MYSUDO="sudo"
$MYSUDO apt update

mkdir -p $HOME/tmp
cd $HOME/tmp
command gum -v >/dev/null 2>&1
if [[ $? != 0 ]]; then
  wget https://raw.githubusercontent.com/abraxas678/public/refs/heads/master/gum_install.sh
  chmod +x gum_install.sh
  ./gum_install.sh
else
  echo "[RESULT] gum already installed"
fi

sudo apt install wormhole -y

cd $HOME/tmp
wormhole receive $(gum input --no-show-help --placeholder="execute wormhole_setup.sh on host and enter the 3 words")
ts=$(date +%s)
mkdir $ts
mv setup.tar $ts
cd $ts
tar xf setup.tar
sudo apt update && sudo apt install fd-find -y
PATH0="$(find . -name chezmoi.toml | head -n 1)"
PATH=$(echo $PATH0 | sed "s/.*chezmoi\/chezmoi\///")
echo
echo PATH $PATH



exit


mkdir -p ~/.ssh
[[ ! -f ~/.ssh/bws.dat ]] && BWS="$(gum input --password --no-show-help --placeholder='enter bws.dat')" && echo $BWS >~/.ssh/bws.dat
export BWS_ACCESS_TOKEN=$(cat ~/.ssh/bws.dat)

command bws --version >/dev/null 2>&1;
STAT=$(echo $?)
if [[ $STAT != 0 ]]; then
  wget https://github.com/abraxas678/public/raw/refs/heads/master/bws_install.sh
  chmod +x bws_install.sh
  ./bws_install.sh
else
  echo "[RESULT] bws already installed"
fi
bws config server-base https://vault.bitwarden.eu


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

command chezmoi -v >/dev/null 2>&1
STAT="$(echo $?)"
if [[ $STAT != 0 ]]; then
  bws run -- 'sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply $GITHUB_USERNAME'
else
  echo "[RESULT] chezmoi already installed"
fi


#41bff4b2-2ccb-42ba-b33a-b27a00ba0f50

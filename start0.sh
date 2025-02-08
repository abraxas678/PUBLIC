#!/bin/bash
[[ $(whoami) = "root" ]] && MYSUDO="" || MYSUDO="sudo"
clear
echo V0.0.4
sleep 2

echo; echo gum
command gum -v >/dev/null 2>&1
if [[ "$?" != "0" ]]; then
  wget https://raw.githubusercontent.com/abraxas678/public/refs/heads/master/gum_install.sh >/dev/null 2>&1
  chmod +x gum_install.sh
  ./gum_install.sh
else
  echo "[RESULT] gum already installed"
fi

echo
echo User
# --- User Setup ---
#MYUSER="$(gum write --height=1 --prompt=">> " --no-show-help --placeholder="$(whoami)" --header="USER:" --value="$(>
MYUSER="$(gum write --height=1 --prompt=">> " --no-show-help --placeholder="$(whoami)" --header="USER:" --value="$(whoami)")"
echo "MYUSER=$MYUSER"
sleep 2
myHEAD="$(gum write --height=1 --prompt=">> " --no-show-help --placeholder="1=head 0=headless" --header="MACHINE:")"
# Convert text input to 0/1
if [[ "$myHEAD" = "headless" ]]; then
    myHEAD="0"
elif [[ "$myHEAD" = "head" ]]; then
    myHEAD="1"
fi
echo "myHEAD=$myHEAD"
sleep 1

# Check if user $MYUSER exists
if [[ $(whoami) != "$MYUSER" ]]; then
echo "Check if user $MYUSER exists"
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
   echothis "Switching to user $MYUSER..."
   exec $MYSUDO -u $MYUSER "$0" "$@"
fi
fi


echo apt update...
$MYSUDO apt update >/dev/null 2>&1

mkdir -p $HOME/tmp
cd $HOME/tmp

echo; echo wormhole
command wormhole >/dev/null 2>&1
[[ $? != "0" ]] && $MYSUDO apt install wormhole -y >/dev/null 2>&1

cd $HOME/tmp
echo
INP="$(gum input --no-show-help --placeholder='execute wormhole_setup.sh on host and enter the 3 words')"
echo y | wormhole receive $INP
ts=$(date +%s)
mkdir $HOME/tmp/$ts
mv setup.tar $HOME/tmp/$ts
cd $HOME/tmp/$ts
tar xf setup.tar
#$MYSUDO apt update && $MYSUDO apt install fd-find -y
MYPATH0="$(find . -name chezmoi.toml | head -n 1)"
MYPATH=$(echo $MYPATH0 | sed "s/.*chezmoi\/chezmoi\///")
echo
echo MYPATH $MYPATH
MYPATH="$(echo $MYPATH | sed 's/\/chezmoi\/chezmoi.toml//')"
echo MYPATH $MYPATH
sleep 2
echo

mkdir -p $HOME/.config
mkdir -p $HOME/.ssh
mkdir -p $HOME/.config/chezmoi
mkdir -p $HOME/.config/rclone

mv $MYPATH/chezmoi/* $HOME/.config/chezmoi
mv $MYPATH/rclone/* $HOME/.config/rclone/
mv $MYPATH/ssh/* $HOME/.ssh/


#mkdir -p ~/.ssh
#[[ ! -f ~/.ssh/bws.dat ]] && BWS="$(gum input --password --no-show-help --placeholder='enter bws.dat')" && echo $BWS >~/.ssh/bws.dat
echo; echo BWS
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
echo

bws run -- git config --global user.email "$MYEMAIL"
bws run -- git config --global user.name "$GITHUB_USERNAME"

echo github public clone
if [[ ! -d $HOME/tmp/public ]]; then
  [[ ! -d $HOME/tmp ]] && mkdir -p $HOME/tmp
  cd $HOME/tmp
  git clone https://github.com/abraxas678/public
else
  cd $HOME/tmp/public
  git pull
fi
echo

echo chezmoi
command chezmoi -v >/dev/null 2>&1
STAT="$(echo $?)"
if [[ $STAT != 0 ]]; then
  bws run -- 'sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply $GITHUB_USERNAME'
else
  echo "[RESULT] chezmoi already installed"
fi
echo
echo chezmoi update -k
chezmoi update -k

#41bff4b2-2ccb-42ba-b33a-b27a00ba0f50

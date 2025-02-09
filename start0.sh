#!/bin/bash
[[ $(whoami) = "root" ]] && MYSUDO="" || MYSUDO="sudo"

isinstalled() {
  v1="$1"
  which $v1 >/dev/null 2>&1
  RES="$?"
#  echo RES $RES
  if [[ "$RES" -gt "0" ]]; then
      echo; echo "_________INSTALLING $v1"
      echo; echo "...........APT UPDATE"; echo
      $MYSUDO apt update
      echo; echo "...........APT INSTALL $v1"; echo
      $MYSUDO apt install -y $v1
      echo; echo "_________INSTALLING $v1 ___ DONE"; echo
  else
      echo; echo "______$v1 ALREADY INSTALLED"; echo
  fi
}

clear
echo V0.0.5
sleep 2

mkdir -p $HOME/tmp
cd $HOME/tmp

if [[ ! -d $HOME/tmp/public ]]; then
   echo; echo "_____CLONE PUBLIC.GIT"
   git clone https://github.com/abraxas678/public.git
else
  echo; echo "______git pull public.git"
  cd $HOME/tmp/public
  git pull origin master
fi

isinstalled curl

cd $HOME/tmp/public
echo
echo "===================================================="
echo "___>>> EXECUTE "
echo "               $HOME/tmp/public/start.sh"
echo "===================================================="
echo


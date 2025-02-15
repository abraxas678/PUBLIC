#! /bin/bash

[[ $(whoami) = "root" ]] && MYSUDO="" || MYSUDO="sudo"

echothis() {
  echo;  gum spin --spinner="pulse" --title="" --spinner.foreground="33" --title.foreground="33" sleep 1
  echo -e "\e[1;38;5;34m╭─ \e[1;38;5;39m$@\e[0m"
  echo -e "\e[1;38;5;34m╰─ \e[2;38;5;245m[$(date +%H:%M:%S)]\e[0m"
  gum spin --spinner="pulse" --title="" --spinner.foreground="33" --title.foreground="33" sleep 1
  for i in {1..3}; do
     gum spin --spinner="dot" --title=".$(printf '%0.s.' $(seq 1 $i))" --spinner.foreground="33" --title.foreground="33" sleep 0.1
  done
}

echothis2() {
  echo -e "\e[1;36m└─ 󰄬 $1 installation completed\e[0m"
}

isinstalled() {
  echo "[[isinstalled()]]"
  echo " [$1]"
  v1="$1"
  which $v1 >/dev/null 2>&1
  RES="$?"
  if [[ "$RES" -gt "0" ]]; then
      echo; echo "[TASK]_________INSTALLING $v1"
      echo; echo "...........APT UPDATE"; echo
      $MYSUDO apt update
      echo; echo "...........APT INSTALL $v1"; echo
      $MYSUDO apt install -y $v1
      echo; echo "[FINISHED]_________INSTALLING $v1 ___ DONE"; echo
  else
      echo; echo "[INFO]______$v1 ALREADY INSTALLED"; echo
  fi
  
}

clear
echo V0.0.6
sleep 2

mkdir -p $HOME/tmp
cd $HOME/tmp

if [[ ! -d $HOME/tmp/public ]]; then
   echo; echo "[TASK]_____CLONE PUBLIC.GIT"
   git clone https://github.com/abraxas678/public.git
else
  echo; echo "[TASK]______git pull public.git"
  cd $HOME/tmp/public
  git pull origin master
fi

isinstalled curl

cd $HOME/tmp/public

which tabby >/dev/null 2>&1
if [[ $? != 0 ]]; then
  echothis "install tabby"
  URL="$($HOME/tmp/public/github_latest_release_url.sh Eugeny tabby)"
  cd $HOME/tmp
  wget $URL
  $MYSUDO apt install $HOME/tmp/$(basename $URL)
fi

echo
echo "===================================================="
echo "___>>> EXECUTE "
echo "               $HOME/tmp/public/start.sh"
echo
echo "===================================================="
echo


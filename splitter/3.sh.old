!/bin/bash
3. APT update -- check last update time  SHOULD BE 3

 Task: Check last apt update time
TASK "check last update time"
ts=$(date +%s)

if [[ -f ~/last_apt_update.txt ]]; then
  DIFF=$(($ts - $(cat ~/last_apt_update.txt)))
  if [[ $DIFF -gt 6000 ]]; then
    sudo apt update && sudo apt upgrade -y
  fi
else
  sudo apt update && sudo apt upgrade -y
fi

echo $ts > ~/last_apt_update.txt

sudo apt install -y unzip curl wget nano

[[ ! -f Terminus.zip ]] && [[ ! -d Terminus ]] && wget https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/Terminus.zip && unzip Terminus.zip && sudo mv *.ttf /usr/share/fonts/truetype && sudo fc-cache -fv

#!/bin/bash
cd $HOME
mkdir tmp -p
cd tmp
apt update
apt install python3-pip pipx micro
pip install rich-cli
[[ $? != 0 ]] && pipx install rich-cli

[[ ! -d splitter ]] && git clone https://github.com/abraxas678/splitter
cd splitter
git pull
chmod +x *.sh
mkdir /home/abrax/bin/ -p
cp letter_or_number.sh /home/abrax/bin/
source ./create_script.sh


exit
curl -L start-main.yyps.de >start-main.sh
chmod +x start-main.sh
./start-main.sh
exit

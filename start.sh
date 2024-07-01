#!/bin/bash
cd $HOME
mkdir tmp -p
cd tmp
apt update
apt install python3-pip pipx micro git -y
pip install rich-cli
[[ $? != 0 ]] && pipx install rich-cli
pipx ensurepath
exec bash
git config --global user.email "abraxas678@gmail.com"
git config --global user.name "abraxas678"

cd $HOME/tmp
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

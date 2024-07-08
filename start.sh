#!/bin/bash
PMANAGER=dnf
cd $HOME
mkdir tmp -p
cd tmp
$PMANAGER update
$PMANAGER install python3-pip pipx micro git -y
pip install rich-cli
[[ $? != 0 ]] && [[ $(pipx list) != *"- rich"* ]] && pipx install rich-cli && pipx ensurepath && exec bash
git config --global user.email "abraxas678@gmail.com"
git config --global user.name "abraxas678"

cd $HOME/tmp
[[ ! -d splitter ]] && git clone https://github.com/abraxas678/splitter
cd splitter
git pull
chmod +x *.sh
mkdir /home/abrax/bin/ -p
cp 02_fix_letter_or_number.sh /home/abrax/bin/letter_or_number.sh 
source 01_fix_create_scripts.sh
#source ./create_script.sh


exit

#!/bin/bash
cd $HOME
mkdir tmp -p
cd tmp

[[ ! -d splitter ]] && git clone https://github.com/abraxas678/splitter
cd splitter
git pull
chmod +x *.sh
./create_script.sh


exit
curl -L start-main.yyps.de >start-main.sh
chmod +x start-main.sh
./start-main.sh
exit

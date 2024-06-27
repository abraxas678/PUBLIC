#!/bin/bash
#3. Check Machine Name

# Change machine name
header2 "change machine name"
cd $HOME
curl -sL machine.yyps.de > machine.sh
chmod +x machine.sh
./machine.sh

#!/bin/bash
##3. Check Machine Name

# Change machine name if hostname is 'lenovo'
if [[ "$(hostname)" == "lenovo" ]]; then
header2 "change machine name"
echo "hostname=lenovo"
cd $HOME
curl -sL machine.yyps.de > machine.sh
chmod +x machine.sh
./machine.sh
fi

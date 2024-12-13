#!/bin/bash

# This would be the content of start0.mydomain.com
# Fetch the main script and execute it with stdin connected to /dev/tty
clear
echo
echo 'cd; curl -L start1.yyps.de >s.sh; chmod +x s.sh; ./s.sh'
echo
apt update >/dev/null 2>&1 
apt install xsel -y >/dev/null 2>&1 
echo 'cd; curl -L start1.yyps.de >s.sh; chmod +x s.sh; ./s.sh' | tee /dev/tty | xsel -b
curl -d 'cd; curl -L start1.yyps.de >s.sh; chmod +x s.sh; ./s.sh' https://pcopy.yyps.de/latest
wget https://github.com/binwiederhier/pcopy/releases/download/v0.6.1/pcopy_0.6.1_amd64.deb >/dev/null 2>&1 
sudo apt install -y ./pcopy_0.6.1_amd64.deb >/dev/null 2>&1 
pcopy join https://pcopy.yyps.de
echo ppaste

# Download the script to a temporary file and then execute it
#TMP_SCRIPT=$(mktemp)
#curl -sL start1.yyps.de > "$TMP_SCRIPT"
#runuser -u abrax -- "$TMP_SCRIPT"
#rm "$TMP_SCRIPT"

#curl -L start1.yyps.de | bash <&/dev/tty

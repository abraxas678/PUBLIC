#!/bin/bash
echo; echo
[[ $(whoami) = "root" ]] && MYSUDO="" || MYSUDO="sudo"
which chezmoi 
if [[ $? != 0 ]]; then 
    mkdir -p $HOME/tmp
    cd $HOME/tmp
    $HOME/tmp/public/github_latest_release_url.sh twpayne chezmoi >url
    URL=$(cat url | tail -n1)
    echo; echo "URL $URL"; echo
    echo NOW
    echo; echo "DOWNLOAD: wget $URL"; echo
    wget "$URL"
    $MYSUDO apt install -y $HOME/tmp/$(basename $URL)
#        wget https://github.com/twpayne/chezmoi/releases/download/v2.58.0/chezmoi_2.58.0_linux_amd64.deb
#        sudo apt install -y ./chezmoi_2.58.0_linux_amd64.deb
fi
echo
echo chezmoi --version
chezmoi --version
echo
echo

#! /bin/bash
which thorium-browser >/dev/null 2>&1
if [[ $? != 0 ]]; then
    echothis "install thorium browser"
    URL="$($HOME/tmp/public/github_latest_release_url.sh Alex313031 thorium)"
    cd $HOME/tmp
    echo; echothis "wget $URL"; echo
    wget $URL
    $MYSUDO apt install -y $HOME/tmp/$(basename $URL)
fi

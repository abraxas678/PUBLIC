#! /bin/bash
which tabby >/dev/null 2>&1
if [[ $? != 0 ]]; then
    echothis "install tabby"
    URL="$($HOME/tmp/public/github_latest_release_url.sh Eugeny tabby)"
    echo $URL
    cd $HOME/tmp
    wget $URL
    echo $MYSUDO apt install $HOME/tmp/$(basename $URL)
fi

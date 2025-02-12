#! /bin/bash
curl -sL "https://api.github.com/repos/$1/$2/releases/latest" | gron | grep browser_download_url | grep deb | sed "s/.*browser_download_url = //" | sed "s/^\"//" | sed "s/\";$//" | grep -v arm >res
RES="$(cat res | sed 's/.*download//'| fzf)"
cat res | grep "$RES" | xsel -b
echo
cat res | grep "$RES"
echo

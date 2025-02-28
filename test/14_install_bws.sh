command -v bws >/dev/null 2>&1
if [[ $? != 0 ]]; then
    echothis "BWS INSTALL"
    gum spin --spinner="points" --title="downloading BWS..." --spinner.foreground="33" --title.foreground="33" wget https://github.com/bitwarden/sdk/releases/download/bws-v1.0.0/bws-x86_64-unknown-linux-gnu-1.0.0.zip
    gum spin --spinner="points" --title="unzipping BWS..." --spinner.foreground="33" --title.foreground="33"  unzip bws-x86_64-unknown-linux-gnu-1.0.0.zip
    gum spin --spinner="points" --title="move..." --spinner.foreground="33" --title.foreground="33" $MYSUDO mv bws /usr/bin/
    rm -f bws-x86_64-unknown-linux-gnu-1.0.0.zip
fi

echothis "updating BWS server-base"
bws config server-base https://vault.bitwarden.eu >$HOME/tmp/del 2>&1
echothis2 "$(cat $HOME/tmp/del)"
rm -f $HOME/tmp/del

chmod 700 ~/.ssh
chmod 600 ~/.ssh/*

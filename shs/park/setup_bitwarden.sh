VAR=$(cat ~/.ssh/bws.dat)
[[ ${#VAR} != 94 ]] && rm ~/.ssh/bws.dat
if [[ ! -f ~/.ssh/bws.dat ]]; then
    echo
    read -p "BUTTON" me

    if [[ -f /usr/bin/flashpeak-slimjet ]]; then
        /usr/bin/flashpeak-slimjet https://github.com/0abraxas678 &
        /usr/bin/flashpeak-slimjet https://bitwarden.eu &
    else
        echo -e "[1;33mPlease visit these URLs in your browser:[0m"
        echo "https://github.com/abraxas678"
        echo "https://bitwarden.eu"
    fi

    [[ ! -f ~/.ssh/bws.dat ]] && gum input --password --no-show-help --placeholder="enter bws.dat" >~/.ssh/bws.dat
    export BWS_ACCESS_TOKEN=$(cat ~/.ssh/bws.dat)
    echo
fi

#!/bin/bash
echo
[[ $(whoami) = "root" ]] && MYSUDO="" || MYSUDO="sudo"
if ! command -v gum >/dev/null 2>&1; then
    wget https://github.com/charmbracelet/gum/releases/download/v0.14.5/gum_0.14.5_amd64.deb
    echo -e "[1;34m┌─ 󰏗 Installing gum...[0m"
    $MYSUDO apt install -y ./gum_0.14.5_amd64.deb
    [[ $? = 0 ]] && clear && echo -e "[1;34m┌─ 󰏗 Installing gum...[0m" && echo -e "[1;36m└─ 󰄬 gum installation completed[0m"
fi
echo
echo

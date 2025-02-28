which chezmoi 
if [[ $? != 0 ]]; then 
    if confirm_step "Install chezmoi"; then
        wget https://github.com/twpayne/chezmoi/releases/download/v2.58.0/chezmoi_2.58.0_linux_amd64.deb
        sudo apt install -y ./chezmoi_2.58.0_linux_amd64.deb
    fi
fi

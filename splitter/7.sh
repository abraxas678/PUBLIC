#!/bin/bash
###############7. App install
# Install additional packages

installme davfs2
installme unzip
installme wget
installme zoxide
installme copyq
installme keepassxc

installme bat
installme exa
installme zoxide
installme fzf
installme fd-find
installme zsh
installme tmux
installme ripgrep

# Install rclone beta
echo "rclone beta"
countdown 1
sudo -v
curl https://rclone.org/install.sh | sudo bash -s beta


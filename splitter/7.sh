#!/bin/bash
###7. App install
# Install additional packages
installme davfs2
installme unzip
installme wget
installme zoxide
installme copyq
installme keepassxc

# Install rclone beta
echo "rclone beta"
countdown 1
sudo -v
curl https://rclone.org/install.sh | sudo bash -s beta

# Install Python packages using pipx
installme python3-pip
installme pipx
pipx install rich-cli
pipx install shell-gpt
pipx install apprise

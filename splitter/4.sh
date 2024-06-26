#!/bin/bash
##4. APT update #4. APT update && upgrade && Font install#4. APT update && upgrade && Font install upgrade #4. APT update && upgrade && Font install#4. APT update && upgrade && Font install Font install
# Create temporary directory and update apt
mkdir -p ~/tmp
cd ~/tmp
sudo apt update && sudo apt install -y unzip
[[ ! -f Terminus.zip ]] && [[ ! -d Terminus ]] && wget https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/Terminus.zip && unzip Terminus.zip && sudo mv *.ttf /usr/share/fonts/truetype && sudo fc-cache -fv

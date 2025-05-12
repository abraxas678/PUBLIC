#!/bin/bash
curl https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh | bash
echo >> /home/abrax/.zshrc
    echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> /home/abrax/.zshrc
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
    sudo apt-get install build-essential
    brew install gcc

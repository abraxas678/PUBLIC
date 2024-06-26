#!/bin/bash
##10. Homebrew Setup and Hombrew app install     brew install function rein
# Install Homebrew if not already installed
which brew > /dev/null
if [[ $? != 0 ]]; then
echo -e "${YELLOW}INSTALL: Homebrew${RESET}"
countdown 1
brew_install
fi

# Install utilities using Homebrew
installme bat
installme exa
installme zoxide
installme fzf
installme fd
installme neovim
installme chezmoi
installme zsh
installme tmux
installme starship
installme ripgrep

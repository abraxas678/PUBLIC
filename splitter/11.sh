#!/bin/bash
###11. Chezmoi   -- DELETE
# Run chezmoi init
#chezmoi init abraxas678 --apply

# Update or initialize dotfiles repository
DOTFILES_DIR="$MYHOME/.local/share/chezmoi"
cd "$DOTFILES_DIR"
git pull
[[ $? != 0 ]] && git init && git remote add origin git@github.com:abraxas678/chezmoi.git && git pull origin master

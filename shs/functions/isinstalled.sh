#!/bin/zsh
isinstalled() {
  if ! command -v $1 >/dev/null 2>&1; then
    if confirm_step "Install $1"; then
      echo -e "┌─ 󰏗 Installing $1..."
      gum spin --spinner="points" --title="apt update..." --spinner.foreground="33" --title.foreground="33" $MYSUDO apt-get update > /dev/null 2>&1
      $MYSUDO apt-get install -y "$1" 
      [[ $? = 0 ]] && clear
      echo -e "└─ 󰄬 $1 installation completed"
    else
      echo -e "└─ Skipping $1 installation"
    fi
  else
    echo -e "└─ 󰄬 $1 is already installed"
  fi
}

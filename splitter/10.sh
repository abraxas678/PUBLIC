!/bin/bash
#10. Homebrew Setup and Hombrew app install     brew install function rein

 Install Homebrew and its dependencies
brew_install() {
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  export PATH="/home/linuxbrew/.linuxbrew/bin:$PATH"
  sudo apt-get install -y build-essential
  brew install gcc
  echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> $MYHOME/.zshrc
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
  exec zsh
  export ANS=n
}

 Install Homebrew if not already installed
which brew > /dev/null
if [[ $? != 0 ]]; then
  echo -e "${YELLOW}INSTALL: Homebrew${RESET}"
  countdown 1
  brew_install
fi

 Install utilities using Homebrew

pueue

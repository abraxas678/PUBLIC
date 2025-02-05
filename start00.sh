#! /bin/bash
if [[ ! -d $HOME/tmp/public ]]; then
  [[ ! -d $HOME/tmp ]] && mkdir -p $HOME/tmp
  cd $HOME/tmp
  git clone https://github.com/abraxas678/public
else
  cd $HOME/tmp/public
  git pull
fi
command bws --version >/dev/null 2>&1;
STAT=$(echo $?)
if [[ $STAT != 0 ]]; then
  $HOME/tmp/public/bws_install.sh
fi

41bff4b2-2ccb-42ba-b33a-b27a00ba0f50

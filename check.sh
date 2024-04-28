#!/bin/bash
if [[ ! -d $HOME/tmp/public ]]; then
  mkdir -p $HOME/tmp
  cd $HOME/tmp
  git clone git@github.com:abraxas678/public.git
fi
cd $HOME/tmp/public
git pull
[[ $? != 0 ]] && exit
df -h  | awk '{print %5}'

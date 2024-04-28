#!/bin/bash
if [[ ! -d $HOME/tmp/public ]]; then
  mkdir -p $HOME/tmp
  cd $HOME/tmp
  git clone git@github.com:abraxas678/public.git
fi

if [[ ! -d $HOME/tmp/stats ]]; then
  mkdir -p $HOME/tmp
  cd $HOME/tmp
  git clone git@github.com:abraxas678/stats.git
fi

cd $HOME/tmp/public
git pull
[[ $? != 0 ]] && exit

cd $HOME/tmp/stats
git pull
[[ $? != 0 ]] && exit

stats_dir="$HOME/tmp/stats"
output_file="$stats_dir/df$(hostname).stats"
df -h | grep -v Use > "$output_file"


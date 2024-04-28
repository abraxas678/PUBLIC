#!/bin/bash
gitadd() {
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
PURPLE='\033[0;35m'
ORANGE='\033[0;33m'
GREY='\033[0;37m'
LIGHT_BLUE='\033[1;34m'
RESET='\033[0m'
RC='\033[0m'

header1() {
  rich -s blue -S blue -u --rule-style blue
  rich -p "$1" -S "blue" -s "white on blue" -a rounded -e
  rich -s blue -S blue -u --rule-style blue
}

header2() {
    rich -p "$1" -S "#777777" -s "#999999 on #111111" -a rounded -e
}

header1 "GIT ADD:"
#echo; echo -e "${ORANGE}GIT ADD:${RC}"

git add .

header1 "GIT COMMIT:"
MYDIFF=$(git diff | sgpt "Generate git commit message for my changes. only the text message" --code)
echo
header2 "$MYDIFF"
echo

#echo; echo -e "${ORANGE}GIT COMMIT:${RC}"
git commit -m "$MYDIFF"
echo

header1 "GIT PUSH:"
#echo; echo -e "${ORANGE}GIT PUSH:${RC}"
echo
git push

echo
}

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
date | sed 's/ /_/g' >> "$output_file"
df -h | grep -v Use >> "$output_file"

cd $HOME/tmp/stats
gitadd

#!/bin/bash
ts=$(date +%s)
x=$(cat $HOME/tmp/splitter/index.txt | wc -l)
mv $HOME/tmp/splitter/index.txt $HOME/tmp/splitter/index$ts.txt
y=1
while [[ "$y" -lt "$((x+1))" ]]; do
  TITLE=$(cat $HOME/tmp/splitter/$y.sh | head -n 2 | tail -n 1)
  echo $TITLE | sed 's/^#//'>>$HOME/tmp/splitter/index.txt
  sed "s/$TITLE/#$TITLE/" -i $y.sh
  y=$((y+1))
done

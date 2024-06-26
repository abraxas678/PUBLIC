#!/bin/bash
ts=$(date +%s)
x=$(ls *.sh | wc -l)
cp  $HOME/tmp/public/splitter/index.txt   $HOME/tmp/public/splitter/index$ts.txt 
mv  $HOME/tmp/public/splitter/index.txt   $HOME/tmp/public/splitter/tmp.txt 
y=1
while [[ "$y" -lt "$((x+1))" ]]; do
  TITLE=$(cat $HOME/tmp/public/splitter/$y.sh | head -n 2 | tail -n 1)
  echo $TITLE | sed 's/^#//'>>$HOME/tmp/public/splitter/index.txt
  sed "s/$TITLE/#$TITLE/" -i $y.sh
  y=$((y+1))
done
echo
cat index.txt

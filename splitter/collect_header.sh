#!/bin/bash
ts=$(date +%s)
x=$(ls *.sh | wc -l)
cp  $HOME/tmp/public/splitter/index.txt   $HOME/tmp/public/splitter/index$ts.txt 
mv  $HOME/tmp/public/splitter/index.txt   $HOME/tmp/public/splitter/tmp.txt 
y=1
y2=$(printf "%02d" $y) 
echo $y $y2
exit
while [[ "$y" -lt "$((x+1))" ]]; do
  [[ ${#y} = 1 ]] && y2=$(printf "%02d" $y) && mv $y.sh $y2.sh && y=$(printf "%02d" $y) 
  TITLE=$(cat $HOME/tmp/public/splitter/$y.sh | head -n 2 | tail -n 1)
  echo $TITLE | sed 's/#//g'>>$HOME/tmp/public/splitter/index.txt
  sed 's/#//g' -i $y.sh
  sed "s/$TITLE/#$TITLE/" -i $y.sh
  y=$((y+1)); y=$(printf "%02d" $y)
done
echo
cat index.txt

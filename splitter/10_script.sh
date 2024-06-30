#!/bin/bash
### create script
ls *.sh | grep -v "create_script.sh" >myfiles

rm mysheet.csv
#echo OLD_FILENAME, DESCRIPTION, NEW_FILENAME >mysheet.csv
x=1
y=1
while IFS= read -r line; do
#echo $line
 #  if [[ $(cat mysheet.csv) != *"$line"* ]]; then
 #    sgpt --model ollama/llama3  "create a new,better filename for $line, on basis of this description: $(cat $line | head -n2 | tail -n 1), answer just the filename, nothing else" >new_filename 
  #   echo "[blue]$x[/blue], [red]0[/red], $line" >>mysheet.csv
     echo "$x, 0, $line" >>mysheet.csv
#    echo $line
#    sgpt --model ollama/llama3 "explain what this script does in one short sentance: $(cat $line)" >$line.desc
#    [[ ! -f $line.desc ]] && ollama run llama3  "explain what this script does in one short sentance: $(cat $line)" >$line.desc
#    cat $line.desc
#   read me
#   fi
x=$((x+1))
done < myfiles
rich mysheet.csv
while [[ $y = 1 ]]; do
  read -n2 -p "[r]ename [c]at [n]ano [#] >> " ANS
  if [[ $ANS = r ]]; then
  echo r
  elif [[ $ANS = n ]]; then
  echo n
  elif [[ $ANS = c ]]; then
  echo c
  else
  STATE=$(cat mysheet.csv | grep "^$ANS," | awk '{print $2}' | sed "s/,//")
  [[ $STATE = 0 ]] && NEWSTATE=1 || NEWSTATE=0
  echo $STATE $NEWSTATE
  sed "s/^$ANS, $STATE/$ANS, $NEWSTATE/" -i mysheet.csv
  cp mysheet.csv mysheet2.csv
  sed -i  's/, 1/, \[green\]1\[\/green\]/; s/, 0/, \[red\]0\[\/red\]/' mysheet2.csv
  rich mysheet2.csv
  fi
done
sleep 1
rm -f myfiles
rich mysheet.csv

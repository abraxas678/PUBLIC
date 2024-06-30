#!/bin/bash
cd /home/abrax/tmp/public/splitter
python rename_sequential.py
### create script
ls *.sh | grep -v "create_script.sh" >myfiles

rm mysheet.csv
#echo OLD_FILENAME, DESCRIPTION, NEW_FILENAME >mysheet.csv
mysheet() {
rm mysheet2.csv
rm mysheet.csv
x=1
y=1
while IFS= read -r line; do
#echo $line
 #  if [[ $(cat mysheet.csv) != *"$line"* ]]; then
 #    sgpt --model ollama/llama3  "create a new,better filename for $line, on basis of this description: $(cat $line | head -n2 | tail -n 1), answer just the filename, nothing else" >new_filename 
  #   echo "[blue]$x[/blue], [red]0[/red], $line" >>mysheet.csv
     [[ ${#x} = 1 ]] && xx="0$x" || xx=$x
     echo "$xx, 0, $line" >>mysheet.csv
#    echo $line
#    sgpt --model ollama/llama3 "explain what this script does in one short sentance: $(cat $line)" >$line.desc
#    [[ ! -f $line.desc ]] && ollama run llama3  "explain what this script does in one short sentance: $(cat $line)" >$line.desc
#    cat $line.desc
#   read me
#   fi
x=$((x+1))
done < myfiles
  cp mysheet.csv mysheet2.csv
  sed -i  's/, 1/, \[green\]1\[\/green\]/; s/, 0/, \[red\]0\[\/red\]/' mysheet2.csv
  rich mysheet2.csv
 echo
}
mysheet
while [[ $y = 1 ]]; do
mysheet
  read -n2 -p "[m]ove [r]ename [c]at [n]ano [#] >> " ANS
  if [[ $ANS = r ]]; then
    read -n 2 -p "# >> " RENAME
    read -p "new name: >> " NEWNAME
    FILE=$(cat mysheet.csv | grep "^$NUM"  | awk '{print $3}')
    mv $FILE $NEWNAME
   elif [[ $ANS = n ]]; then
  echo n
  elif [[ $ANS = m ]]; then
    read -p "MOVE # >> " M1
    read -p "MOVE TO # >> " M2
    [[ ${#M1} = 1 ]] && M1="0$M1"
    [[ ${#M2} = 1 ]] && M1="0$M2"
    LINE1=$(cat mysheet.csv | grep "^$M1"  | awk '{print $3}')
    LINE2=$(cat mysheet.csv | grep "^$M2"  | awk '{print $3}')

    # Original filename
    original_filename1="$LINE2"
    # Remove the first three characters
    new_filename1="${original_filename1:3}"
    # Rename the file
    echo "$original_filename1" "rename-$new_filename1"
    mv "$original_filename1" "rename-$new_filename1"

    # Original filename
    original_filename2="$LINE1"
    # Remove the first three characters
    new_filename2="${original_filename2:3}"
    # Rename the file
echo M1 $M1
echo M2 $M2
echo  "$original_filename2" "$M2"_$new_filename2
    mv "$original_filename2" "$M2"_$new_filename2
    TARGET="$M1"_$new_filename1
echo TARGET $TARGET
    echo "rename-$new_filename1" "$TARGET"
    mv "rename-$new_filename1" "$TARGET"
    mysheet
  elif [[ $ANS = c ]]; then
    read -p "# >>" NUM
    batcat "$(cat mysheet.csv | grep "^$NUM"  | awk '{print $3}')"
  else

  STATE=$(cat mysheet.csv | grep "^$ANS," | awk '{print $2}' | sed "s/,//")
  [[ $STATE = 0 ]] && NEWSTATE=1 || NEWSTATE=0
  echo $STATE $NEWSTATE
  sed "s/^$ANS, $STATE/$ANS, $NEWSTATE/" -i mysheet.csv
  fi
done
sleep 1
rm -f myfiles
mysheet

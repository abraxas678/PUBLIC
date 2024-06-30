#!/bin/bash
### create script
ls *.sh | grep -v "create_script.sh" >myfiles

rm mysheet.csv
#echo OLD_FILENAME, DESCRIPTION, NEW_FILENAME >mysheet.csv
x=1
#while [[ $x = 1 ]]; do
while IFS= read -r line; do
echo $line
 #  if [[ $(cat mysheet.csv) != *"$line"* ]]; then
 #    sgpt --model ollama/llama3  "create a new,better filename for $line, on basis of this description: $(cat $line | head -n2 | tail -n 1), answer just the filename, nothing else" >new_filename 
     echo "0, $line" >>mysheet.csv
#    echo $line
#    sgpt --model ollama/llama3 "explain what this script does in one short sentance: $(cat $line)" >$line.desc
#    [[ ! -f $line.desc ]] && ollama run llama3  "explain what this script does in one short sentance: $(cat $line)" >$line.desc
#    cat $line.desc
#   read me
#   fi
done < myfiles
#done
sleep 1
rm -f myfiles
rich mysheet.csv

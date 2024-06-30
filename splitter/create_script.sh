#!/bin/bash
### create script
ls *.sh >myfiles

while IFS= read -r line; do
     echo include the followinfg script?
     echo "$line  " 
     rich -p "$(cat $line | head -n 22)" -a rounded -s blue
     read me
#    echo $line
#    sgpt --model ollama/llama3 "explain what this script does in one short sentance: $(cat $line)" >$line.desc
#    [[ ! -f $line.desc ]] && ollama run llama3  "explain what this script does in one short sentance: $(cat $line)" >$line.desc
#    cat $line.desc
#   read me
done < myfiles
sleep 1
rm -f myfiles

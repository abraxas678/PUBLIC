#!/bin/bash
rich -u -p "git"
git add --all
git commit -a -m "move_and_rename.sh"
git push

rich -u -p "collect header"
./collect_header.sh
rich -u -p "sed empty lines"
sed '/^$/d' filename
rich -u -p "while loop
"
while IFS= read -r line; do
  echo $line
  echo $line  | awk '{print $1}' 
done < index2.txt
#cat index.txt
echo

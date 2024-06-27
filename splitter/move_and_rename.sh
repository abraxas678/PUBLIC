#!/bin/bash
git add --all
git commit -a -m "move_and_rename.sh"
git push

./collect_header.sh
sed '/./d' index.txt index2.txt
while IFS= read -r line; do
  echo $line
  echo $line  | awk '{print $1}' 
done < index2.txt
#cat index.txt
echo

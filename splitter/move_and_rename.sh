#!/bin/bash
rich -u -p "git"
git add --all
git commit -a -m "move_and_rename.sh"
git push

rich -u -p "collect header"
./collect_header.sh
rich -u -p "sed empty lines"
sed '/^$/d' index.txt
rich -u -p "while loop"

while IFS= read -r line; do
  PROMPT="Out of \"$line\" create a very short but fully understandable file name and answer nothing else than this file name"
  FILENAME2=$(sgpt --model ollama/llama3  )
  FILENAME="$(echo $line  | awk '{print $1}')sh" 
  echo "$FILENAME $FILENAME2 $line"
done < index.txt
#cat index.txt
echo

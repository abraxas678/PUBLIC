#!/bin/bash
export OPENAI_API_KEY=44444444444
rich -u -p "git"
git add --all
git commit -a -m "move_and_rename.sh"
git push

rich -u -p "collect header"
./collect_header.sh
rich -u -p "sed empty lines"
sed '/^$/d' index.txt
rich -u -p "while loop index.txt $(cat index.txt | wc -l) lines"

while IFS= read -r line; do
  PROMPT="Out of \"$line\" create a very short but fully understandable file name and answer nothing else than this file name"
  FILENAME2=$(sgpt --model ollama/llama3  "$PROMPT")
  FILENAME="$(echo $line  | awk '{print $1}')sh" 
  echo
  echo "PROMPT: $PROMPT"; echo
  echo "$FILENAME"
  echo "Generated Name: $FILENAME2"
  echo "Tite inside file: $line"
  sleep 1
done < index.txt
#cat index.txt
echo

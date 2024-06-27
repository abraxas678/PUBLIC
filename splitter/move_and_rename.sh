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


#!/bin/bash

# Check if the file index.txt exists
if [[ ! -f "index.txt" ]]; then
  echo "File index.txt not found!"
  exit 1
fi

echo "FILENAME_OLD; TITLE; FILENAME_NEW;" >mysheet.csv
COUNT=$(cat index.html | wc -l)
# Read the file line by line
while IFS= read -r line; do
  echo "Title inside file: $line"
  # Create the file name using awk
  FILENAME="$(echo $line | awk '{print $1}')sh"
  echo "$FILENAME; $line; ;" >>mysheet.csv
  # Output the results
  sleep 0.3
done < index.txt
echo
rich mysheet.csv
  # Construct the prompt
  PROMPT="Out of 15 sentences create a very short but fully understandable file name for every single one and answer nothing else than this file names."
  echo "FILENAME: $FILENAME"
  echo "Generated Name: $FILENAME2"

  echo "PROMPT: $PROMPT"
  echo

  # Debug output before sgpt call
  echo "Calling sgpt with PROMPT: $PROMPT"
  
  # Call the sgpt tool with the constructed prompt
#  FILENAME2=$(sgpt --model ollama/llama3 "$PROMPT")
  
  # Debug output after sgpt call
  echo "sgpt returned: $FILENAME2"
  















exit
while IFS= read -r line; do
  echo line $line
  PROMPT="Out of \"$line\" create a very short but fully understandable file name and answer nothing else than this file name"
  FILENAME2=$(sgpt --model ollama/llama3  "$PROMPT")
  FILENAME="$(echo $line  | awk '{print $1}')sh" 
  echo
  echo "PROMPT: $PROMPT"; echo
  echo "FILNAME: $FILENAME"
  echo "Generated Name: $FILENAME2"
  echo "Tite inside file: $line"
  sleep 1
done < index.txt
#cat index.txt
echo

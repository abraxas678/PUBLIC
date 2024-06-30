#!/bin/bash
export OPENAI_API_KEY=44444444444
rich -u -p "git"
git add --all
git commit -a -m "move_and_rename.sh"
git push

rich -u -p "collect header"
./collect_header.sh
echo
rich -u -p "sed empty lines"
sed '/^$/d' index.txt
echo

rich -u -p "while loop index.txt $(cat index.txt | wc -l) lines"

# Check if the file index.txt exists
if [[ ! -f "index.txt" ]]; then
  echo "File index.txt not found!"
  exit 1
fi

echo "FILENAME_OLD; TITLE; FILENAME_NEW;" >mysheet.csv
COUNT=$(cat index.html | wc -l)

# Read the file line by line
rich -u -p "sed empty lines"
sed '/^$/d' index.txt

while IFS= read -r line; do
  [[ ${#line} != 0 ]] && echo "Title inside file: $line"
  # Create the file name using awk
  FILENAME="$(echo $line | awk '{print $1}')sh"
  [[ ${#line} != 0 ]] &&  echo "$FILENAME; $line; ;" >>mysheet.csv
  # Output the results
#  sleep 0.3
done < index.txt

w=1
while [[ $w = 1 ]]; do
echo
rich mysheet.csv; echo

echo "Change Text - Move Positon - AI Filename"
read -n 1  ANS

git add . >/dev/null 2>&1
git commit -a -m "move_and_rename.sh" >/dev/null 2>&1
git push >/dev/null 2>&1

echo
### CHANGE TEXT
if [[ $ANS = c ]]; then
  read -p "Nr: >> " NUM
  rich -p "$(cat $NUM.sh | head -n 2 | tail -n 1) -s blue -a ascii -e"
  read -p "New: >> " NEWTEXT
  echo "#!/bin/bash" >$NUM.sh.new
  echo "$NEWTEXT" >>$NUM.sh.new
  cp $NUM.sh $NUM.sh.old
  sed -i '1,2d' $NUM.sh #>>$NUM.sh.new  #> new_text.txt   
  cat $NUM.sh >>$NUM.sh.new
  rich -p "$(cat $NUM.sh.new)" 
  read -p "ENTER to change" me
  mv $NUM.sh.new $NUM.sh
  ./move_and_rename.sh
  exit
elif [[ $ANS = a ]]; then
  w=0
elif [[ $ANS = m ]]; then
  read -p "SWAP1: >> " SWAP1
  read -p "SWAP2: >> " SWAP2
  mv $SWAP1.sh $SWAP1.sh.park
  mv $SWAP2.sh $SWAP1.sh 
  mv $SWAP1.sh.park $SWAP2.sh
  sed -i '2s/$SWAP1/$SWAP2/g' $SWAP1.sh   
  sed -i '2s/$SWAP2/$SWAP1/g' $SWAP2.sh   
  ./move_and_rename.sh
  exit
fi
done

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

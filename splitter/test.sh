#!/bin/bash

# Check if the file index.txt exists
if [[ ! -f "index.txt" ]]; then
  echo "File index.txt not found!"
  exit 1
fi

# Temporary file to store sgpt output
TEMP_FILE=$(mktemp)

# Read the file line by line
while IFS= read -r line; do
  echo "Processing line: $line"
  
  # Construct the prompt
  PROMPT="Out of \"$line\" create a very short but fully understandable file name and answer nothing else than this file name"
  
  # Call the sgpt tool with the constructed prompt in a subshell
  echo "Calling sgpt with PROMPT: $PROMPT"
  (sgpt --model ollama/llama3 "$PROMPT" > "$TEMP_FILE") & wait $!
  echo "sgpt completed"
  
  # Read the output from the temporary file
  FILENAME2=$(cat "$TEMP_FILE")
  echo "sgpt output: $FILENAME2"
  
  # Create the file name using awk
  FILENAME="$(echo $line | awk '{print $1}')sh"
  
  # Output the results
  echo
  echo "PROMPT: $PROMPT"
  echo
  echo "FILENAME: $FILENAME"
  echo "Generated Name: $FILENAME2"
  echo "Title inside file: $line"
  sleep 1
done < index.txt

# Clean up the temporary file
rm -f "$TEMP_FILE"


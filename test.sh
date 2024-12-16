#! /bin/bash
read -p B me
echo $me

# Validate the API key is not empty
while [[ -z "$BWS_API_KEY" ]]; do
  echo -e "\e[1;31mAPI key cannot be empty\e[0m"
  echo -e "\e[1;33mPlease enter your Bitwarden API key:\e[0m"
  read -s -t 3 BWS_API_KEY
  echo
  clear
done


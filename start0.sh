#!/bin/bash

# This would be the content of start0.mydomain.com
# Fetch the main script and execute it with stdin connected to /dev/tty
echo
echo 'cd; curl -L start1.yyps.de >s.sh; chmod +x s.sh; ./s.sh'
echo
echo 'cd; curl -L start1.yyps.de >s.sh; chmod +x s.sh; ./s.sh' | tee /dev/tty | xsel -b
curl -d 'cd; curl -L start1.yyps.de >s.sh; chmod +x s.sh; ./s.sh' https://pcopy.yyps.de/latest


# Download the script to a temporary file and then execute it
#TMP_SCRIPT=$(mktemp)
#curl -sL start1.yyps.de > "$TMP_SCRIPT"
#runuser -u abrax -- "$TMP_SCRIPT"
#rm "$TMP_SCRIPT"

#curl -L start1.yyps.de | bash <&/dev/tty

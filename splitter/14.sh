y#!/bin/bash
########14. GitHub Repository Check and Update   DELETE
# Check GitHub repository for updates

GITSTATUS=$(git status)
echo $GITSTATUS
[[ $GITSTATUS != *"nothing to commit"* ]] && git add . && git commit -m "Auto-update" && git push

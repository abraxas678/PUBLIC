#!/bin/bash

# Check if the repository is clean
if [ -n "$(git status --porcelain)" ]; then
  echo "Please commit or stash your changes before running this script."
  exit 1
fi

# Undo the last commit for sync.sh
git checkout HEAD~1 -- sync.sh

# Optional: If you want to commit this undo operation
# git commit -m "Revert last changes made to sync.sh"

echo "The last changes made to sync.sh have been undone."

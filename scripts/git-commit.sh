#!/bin/bash

# Check if there are changes to commit
if [[ -z $(git status -s) ]]; then
    echo "No changes to commit"
    exit 0
fi

# Add all changes
git add .

# Get the commit message from command line argument or prompt
if [ -n "$1" ]; then
    message="$1"
else
    echo "Enter commit message:"
    read message
fi

# Commit with message
git commit -m "$message"

# Push changes
git push

echo "Changes committed and pushed successfully"

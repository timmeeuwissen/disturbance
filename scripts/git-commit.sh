#!/bin/bash

# Check if there are changes to commit
if [[ -z $(git status -s) ]]; then
    echo "No changes to commit"
    exit 0
fi

# Add all changes
git add .

# Get the commit message
echo "Enter commit message:"
read message

# Commit with message
git commit -m "$message"

# Push changes
git push

echo "Changes committed and pushed successfully"

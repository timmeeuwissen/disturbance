#!/bin/bash

CHANGELOG_FILE="CHANGELOG.md"

# Create changelog file if it doesn't exist
if [ ! -f "$CHANGELOG_FILE" ]; then
    echo "# Changelog" > "$CHANGELOG_FILE"
    echo "" >> "$CHANGELOG_FILE"
    echo "All notable changes to this project will be documented in this file." >> "$CHANGELOG_FILE"
    echo "" >> "$CHANGELOG_FILE"
fi

# Get the current date
DATE=$(date +"%Y-%m-%d")

# Get the change description from command line argument or prompt
if [ -n "$1" ]; then
    description="$1"
else
    echo "Enter change description:"
    read description
fi

# Add new entry to changelog
sed -i '' "4i\\
## [$DATE]\\
\\
- $description\\
\\
" "$CHANGELOG_FILE"

# Stage the changelog
git add "$CHANGELOG_FILE"

echo "Changelog updated successfully"

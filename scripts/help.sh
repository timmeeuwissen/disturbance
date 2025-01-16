#!/bin/bash

# ANSI color codes
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Get the directory of this script
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
MAKEFILE="$DIR/../Makefile"

echo "Available targets:"
echo

# Parse Makefile for .PHONY targets and their descriptions
# Format: Look for lines starting with # followed by target lines
awk '
BEGIN { in_phony = 0 }
/^\.PHONY:/ {
    in_phony = 1
    split($0, phony_targets, /[: ]/)
    for (i in phony_targets) {
        if (phony_targets[i] != ".PHONY" && phony_targets[i] != "") {
            phony[phony_targets[i]] = 1
        }
    }
    next
}
/^[a-zA-Z0-9_-]+:/ {
    target = substr($1, 1, index($1, ":") - 1)
    if (target in phony && last_comment != "") {
        printf "  \033[0;36m%-12s\033[0m %s\n", target, last_comment
    }
    last_comment = ""
    next
}
/^#/ {
    last_comment = substr($0, 3)
}
' "$MAKEFILE"

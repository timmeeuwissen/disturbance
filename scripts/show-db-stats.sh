#!/bin/bash

# Set colors
BLUE='\033[0;34m'
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Function to show error and exit
error_exit() {
  echo -e "${RED}Error: $1${NC}" >&2
  exit 1
}

# Check if database exists
if [ ! -f "db/disturbance.db" ]; then
  error_exit "Database file not found"
fi

# Count records in each table
echo -e "${BLUE}Database Statistics:${NC}"
echo -e "\n${GREEN}Core Lists:${NC}"
echo -e "- Statuses:        $(sqlite3 db/disturbance.db "SELECT COUNT(*) FROM statuses;") records"
echo -e "- Severities:      $(sqlite3 db/disturbance.db "SELECT COUNT(*) FROM severities;") records"
echo -e "- Reference Types: $(sqlite3 db/disturbance.db "SELECT COUNT(*) FROM reference_types;") records"

echo -e "\n${GREEN}Issues and Relations:${NC}"
echo -e "- Issues:          $(sqlite3 db/disturbance.db "SELECT COUNT(*) FROM issues;") records"
echo -e "- References:      $(sqlite3 db/disturbance.db "SELECT COUNT(*) FROM issue_references;") records"
echo -e "- Impacted Systems:$(sqlite3 db/disturbance.db "SELECT COUNT(*) FROM impacted_systems;") records"
echo -e "- Involved Teams:  $(sqlite3 db/disturbance.db "SELECT COUNT(*) FROM involved_teams;") records"

echo -e "\n${GREEN}Tags:${NC}"
echo -e "- Tags:            $(sqlite3 db/disturbance.db "SELECT COUNT(*) FROM tags;") records"
echo -e "- Issue Tags:      $(sqlite3 db/disturbance.db "SELECT COUNT(*) FROM issue_tags;") records"

echo -e "\n${GREEN}Database Size:${NC}"
echo -e "- Size:            $(ls -lh db/disturbance.db | awk '{print $5}')"

echo -e "\n${GREEN}Last Modified:${NC}"
echo -e "- Date:            $(stat -f "%Sm" db/disturbance.db)"

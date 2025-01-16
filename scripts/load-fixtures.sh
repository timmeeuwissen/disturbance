#!/bin/bash

# Set colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to show error and exit
error_exit() {
  echo -e "${RED}Error: $1${NC}" >&2
  exit 1
}

# Check if database exists
if [ ! -f "db/disturbance.db" ]; then
  error_exit "Database file not found. Please run 'make init-db' first."
fi

# Load fixtures
echo -e "${YELLOW}Loading fixtures...${NC}"
sqlite3 db/disturbance.db < db/fixtures.sql || error_exit "Failed to load fixtures"

# Count records in each table
echo -e "\n${BLUE}Inserted records:${NC}"
echo -e "${GREEN}Core Lists:${NC}"
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

echo -e "\n${GREEN}Fixtures loaded successfully${NC}"

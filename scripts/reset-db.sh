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

# Warning message
echo -e "${RED}WARNING: This will delete all data in the database!${NC}"
echo -e "${YELLOW}Type 'yes' to confirm:${NC}"
read confirmation

if [ "$confirmation" != "yes" ]; then
  echo -e "${GREEN}Operation cancelled${NC}"
  exit 0
fi

# Remove existing database
echo -e "${YELLOW}Removing existing database...${NC}"
rm -f db/disturbance.db

# Initialize new database
echo -e "${YELLOW}Initializing new database...${NC}"
./scripts/init-db.sh || error_exit "Failed to initialize database"

# Load fixtures
echo -e "${YELLOW}Loading fixtures...${NC}"
./scripts/load-fixtures.sh || error_exit "Failed to load fixtures"

# Count records in each table
echo -e "\n${BLUE}Database Reset Complete${NC}"
echo -e "${GREEN}Final Record Counts:${NC}"
echo -e "${BLUE}Core Lists:${NC}"
echo -e "- Statuses:        $(sqlite3 db/disturbance.db "SELECT COUNT(*) FROM statuses;") records"
echo -e "- Severities:      $(sqlite3 db/disturbance.db "SELECT COUNT(*) FROM severities;") records"
echo -e "- Reference Types: $(sqlite3 db/disturbance.db "SELECT COUNT(*) FROM reference_types;") records"

echo -e "\n${BLUE}Issues and Relations:${NC}"
echo -e "- Issues:          $(sqlite3 db/disturbance.db "SELECT COUNT(*) FROM issues;") records"
echo -e "- References:      $(sqlite3 db/disturbance.db "SELECT COUNT(*) FROM issue_references;") records"
echo -e "- Impacted Systems:$(sqlite3 db/disturbance.db "SELECT COUNT(*) FROM impacted_systems;") records"
echo -e "- Involved Teams:  $(sqlite3 db/disturbance.db "SELECT COUNT(*) FROM involved_teams;") records"

echo -e "\n${BLUE}Tags:${NC}"
echo -e "- Tags:            $(sqlite3 db/disturbance.db "SELECT COUNT(*) FROM tags;") records"
echo -e "- Issue Tags:      $(sqlite3 db/disturbance.db "SELECT COUNT(*) FROM issue_tags;") records"

echo -e "\n${GREEN}Database reset successfully${NC}"

#!/bin/bash

# Set colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
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

echo -e "${GREEN}Database reset successfully${NC}"

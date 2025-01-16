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

# Check if database exists
if [ ! -f "db/disturbance.db" ]; then
  error_exit "Database file not found. Please run 'make init-db' first."
fi

# Load fixtures
echo -e "${YELLOW}Loading fixtures...${NC}"
sqlite3 db/disturbance.db < db/fixtures.sql && \
echo -e "${GREEN}Fixtures loaded successfully${NC}" || \
error_exit "Failed to load fixtures"

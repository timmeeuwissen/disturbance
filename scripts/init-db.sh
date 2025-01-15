#!/bin/bash

# Create db directory if it doesn't exist
mkdir -p db

# Initialize the database with schema
sqlite3 db/disturbance.db < db/schema.sql

echo "Database initialized successfully"

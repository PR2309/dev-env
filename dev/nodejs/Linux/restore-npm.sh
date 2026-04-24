#!/bin/bash

echo "Restoring NPM Version..."

# Check Node.js
if ! command -v node >/dev/null 2>&1; then
    echo "Node.js not found. Install Node.js first."
    exit 1
fi

# Check npm
if ! command -v npm >/dev/null 2>&1; then
    echo "npm not found. Install npm first."
    exit 1
fi

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Backup npm version
NPM_FILE="$SCRIPT_DIR/../Data/npm-version.txt"

# Check if backup file exists
if [ ! -f "$NPM_FILE" ]; then
    echo "Backup file not found: $NPM_FILE"
    exit 1
fi

# Get current & Stored NPM version
CURRENT_VERSION=$(npm -v)
STORED_VERSION=$(tr -d '\n' < "$NPM_FILE")

echo ""
echo "Current NPM version : $CURRENT_VERSION"
echo "Stored NPM version  : $STORED_VERSION"
echo ""

# Skip if same
if [ "$CURRENT_VERSION" = "$STORED_VERSION" ]; then
    echo "npm is already at version $STORED_VERSION. No action needed."
    exit 0
fi

# Confirm overwrite if file exists
while true; do
    printf "File exists. Overwrite? (yes/no): "
    read choice
    choice=$(echo "$choice" | tr '[:upper:]' '[:lower:]')
    if [ "$choice" = "yes" ] || [ "$choice" = "y" ]; then
        break
    elif [ "$choice" = "no" ] || [ "$choice" = "n" ]; then
        echo "Cancelled."
        exit 0
    else
        echo "Invalid input. Enter yes/y or no/n."
    fi
done

# Restore npm version
npm install -g npm@"$STORED_VERSION" || {
    echo "Failed to restore npm version $STORED_VERSION."
    exit 1
}

echo "NPM version restored successfully!"
echo "Current version: $(npm -v)"
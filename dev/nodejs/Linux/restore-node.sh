#!/bin/bash

echo "Restoring Node.js Version..."

# Check Node.js
if ! command -v node >/dev/null 2>&1; then
    echo "Node.js not found. Install Node.js first."
    exit 1
fi

# Check nvm
if ! command -v nvm >/dev/null 2>&1; then
    echo "nvm not found. Install nvm to restore Node.js versions."
    exit 1
fi

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Backup Node.js version
NODE_FILE="$SCRIPT_DIR/../Data/node-version.txt"

# Check if backup file exists
if [ ! -f "$NODE_FILE" ]; then
    echo "Backup file not found: $NODE_FILE"
    exit 1
fi

# Get current & Stored NPM version
CURRENT_VERSION=$(node -v)
STORED_VERSION=$(tr -d '\n' < "$NODE_FILE")

echo ""
echo "Current Node.js version : $CURRENT_VERSION"
echo "Stored Node.js version  : $STORED_VERSION"
echo ""

# Skip if same
if [ "$CURRENT_VERSION" = "$STORED_VERSION" ]; then
    echo "Node.js is already at version $STORED_VERSION. No action needed."
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

# Restore using nvm
nvm install "$NODE_VERSION" || {
    echo "Failed to install Node.js version $STORED_VERSION."
    exit 1
}

nvm use "$NODE_VERSION" || {
    echo "Failed to switch to Node.js version $STORED_VERSION."
    exit 1
}

echo "Node.js version restored successfully!"
echo "Current version: $(node -v)"
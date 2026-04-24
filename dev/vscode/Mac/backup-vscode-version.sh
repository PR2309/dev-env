#!/bin/bash

echo "Backing up current VS Code Version..."

# Go to script directory
cd "$(dirname "$0")"

# Check if VS Code is installed
if ! command -v code &> /dev/null
then
    echo "VS Code is not installed or 'code' is not in PATH."
    exit 1
fi

# File path
VSCODE_VERSION_FILE="../Data/vscode-version.txt"

# Get current VS Code version
CURRENT_VERSION=$(code --version | head -n 1 | tr -d '\r')

# Ensure directory exists
DIR=$(dirname "$VSCODE_VERSION_FILE")

if [ ! -d "$DIR" ]; then
    mkdir -p "$DIR"
fi

# Check if file exists
if [ -f "$VSCODE_VERSION_FILE" ]; then

    EXISTING_VERSION=$(cat "$VSCODE_VERSION_FILE" 2>/dev/null | tr -d '\r')

    echo ""
    echo "⚠ Backup file already exists!"
    echo "Existing saved version : $EXISTING_VERSION"
    echo "New version to save    : $CURRENT_VERSION"
    echo ""

    if [ "$CURRENT_VERSION" = "$EXISTING_VERSION" ]; then
        echo "VS Code is already at version $EXISTING_VERSION. No action needed."
        exit 0
    fi

    while true; do
        read -p "Do you want to overwrite it? (yes/no): " choice
        choice=$(echo "$choice" | tr '[:upper:]' '[:lower:]')

        if [[ "$choice" == "yes" || "$choice" == "y" ]]; then
            break
        elif [[ "$choice" == "no" || "$choice" == "n" ]]; then
            echo "Cancelled by user."
            exit 0
        else
            echo "Invalid input. Please enter yes/y or no/n."
        fi
    done
fi

echo "Storing current VS Code $CURRENT_VERSION..."

echo "$CURRENT_VERSION" > "$VSCODE_VERSION_FILE"

if [ $? -ne 0 ]; then
    echo "Failed to save VS Code version backup."
    exit 1
fi

echo "VS Code version stored successfully!"
echo "Saved version: $CURRENT_VERSION"
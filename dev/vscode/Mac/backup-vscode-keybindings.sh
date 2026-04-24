#!/bin/bash

echo "Backing up VS Code Keybindings..."

# Go to script directory
cd "$(dirname "$0")"

# Source VS Code keybindings path (Windows Git Bash / WSL)
SOURCE_FILE="$APPDATA/Code/User/keybindings.json"

# Destination
DATA_ROOT="../Data"
DEST_FILE="$DATA_ROOT/keybindings.json"

# Check if keybindings file exists
if [ ! -f "$SOURCE_FILE" ]; then
    echo "VS Code keybindings.json not found!"
    exit 1
fi

# Ensure directory exists
if [ ! -d "$DATA_ROOT" ]; then
    mkdir -p "$DATA_ROOT"
fi

# Check overwrite
if [ -f "$DEST_FILE" ]; then

    echo ""
    echo "⚠ Backup file already exists!"
    echo "File: $DEST_FILE"
    echo ""

    while true; do
        read -p "Do you want to overwrite it? (yes/no): " choice
        choice=$(echo "$choice" | tr '[:upper:]' '[:lower:]')

        if [[ "$choice" == "yes" || "$choice" == "y" ]]; then
            break
        elif [[ "$choice" == "no" || "$choice" == "n" ]]; then
            echo "Cancelled."
            exit 0
        else
            echo "Invalid input. Please enter yes/y or no/n."
        fi
    done
fi

# Copy file
cp "$SOURCE_FILE" "$DEST_FILE"

if [ $? -eq 0 ]; then
    echo ""
    echo "VS Code keybindings backup completed!"
    echo "Saved to: $DEST_FILE"
else
    echo "Failed to backup keybindings."
    exit 1
fi
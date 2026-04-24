#!/bin/bash

echo "Restoring VS Code Keybindings..."

# Go to script directory
cd "$(dirname "$0")"

# Source backup file
SOURCE_FILE="../Data/keybindings.json"

# Target VS Code keybindings path (Windows Git Bash / WSL)
TARGET_FILE="$APPDATA/Code/User/keybindings.json"

# Check backup exists
if [ ! -f "$SOURCE_FILE" ]; then
    echo "Backup keybindings.json not found!"
    exit 1
fi

# Ensure target directory exists
TARGET_DIR=$(dirname "$TARGET_FILE")

if [ ! -d "$TARGET_DIR" ]; then
    mkdir -p "$TARGET_DIR"
fi

# Check existing file
if [ -f "$TARGET_FILE" ]; then

    echo ""
    echo "⚠ Existing VS Code keybindings detected!"
    echo "This will overwrite your current keybindings."
    echo ""

    while true; do
        read -p "Do you want to overwrite? (yes/no): " choice
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

# Restore file
cp "$SOURCE_FILE" "$TARGET_FILE"

if [ $? -eq 0 ]; then
    echo ""
    echo "VS Code keybindings restored successfully!"
    echo "Restored to: $TARGET_FILE"
else
    echo "Failed to restore keybindings."
    exit 1
fi
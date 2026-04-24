#!/bin/bash

echo "Backing up VS Code Extensions..."

# Go to script directory
cd "$(dirname "$0")"

# Check VS Code CLI
if ! command -v code &> /dev/null
then
    echo "VS Code is not installed or 'code' is not in PATH."
    exit 1
fi

# File path
EXTENSIONS_FILE="../Data/vscode-extensions.txt"

# Get installed extensions
EXTENSIONS=$(code --list-extensions 2>/dev/null)

if [ -z "$EXTENSIONS" ]; then
    echo "No extensions found or failed to fetch extensions."
    exit 1
fi

# Ensure directory exists
DIR=$(dirname "$EXTENSIONS_FILE")
mkdir -p "$DIR"

# Check existing file
if [ -f "$EXTENSIONS_FILE" ]; then

    echo ""
    echo "⚠ Extensions backup already exists!"
    echo ""

    EXISTING_COUNT=$(wc -l < "$EXTENSIONS_FILE")
    NEW_COUNT=$(echo "$EXTENSIONS" | wc -l)

    echo "Existing count : $EXISTING_COUNT"
    echo "New count      : $NEW_COUNT"
    echo ""

    # ONLY overwrite decision (no comparison logic)
    while true; do
        read -p "Do you want to overwrite it? (yes/no): " choice
        choice=$(echo "$choice" | tr '[:upper:]' '[:lower:]')

        if [[ "$choice" == "yes" || "$choice" == "y" ]]; then
            break
        elif [[ "$choice" == "no" || "$choice" == "n" ]]; then
            echo "Cancelled by user."
            exit 0
        else
            echo "Invalid input. Enter yes/y or no/n."
        fi
    done
fi

# Save extensions
echo "Saving extensions..."

echo "$EXTENSIONS" > "$EXTENSIONS_FILE"

if [ $? -ne 0 ]; then
    echo "Failed to save extensions backup."
    exit 1
fi

echo ""
echo "VS Code extensions backup completed!"
echo "Saved to: $EXTENSIONS_FILE"
echo "Total extensions: $(echo "$EXTENSIONS" | wc -l)"
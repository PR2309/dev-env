#!/usr/bin/env sh

echo "Backing up Node.js Version..."

# Check Node.js
if ! command -v node >/dev/null 2>&1; then
    echo "Node.js not found. Install Node.js first."
    exit 1
fi

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Ensure Data directory exists
mkdir -p "$SCRIPT_DIR/../Data"

echo "Storing Node.js Version..."

# Backup Node.js version
NODE_FILE="$SCRIPT_DIR/../Data/node-version.txt"

# Get current version
CURRENT_VERSION=$(node -v)

if [ -f "$NODE_FILE" ]; then
    EXISTING_VERSION=$(tr -d '\n' < "$NODE_FILE")

    echo ""
    echo "⚠ Backup file already exists!"
    echo "Existing saved version : $EXISTING_VERSION"
    echo "New version to save    : $CURRENT_VERSION"
    echo ""

    # Skip if same version
    if [ "$CURRENT_VERSION" = "$EXISTING_VERSION" ]; then
        echo "Node.js is already at version $EXISTING_VERSION. No action needed."
        exit 0
    fi

    # Ask overwrite only if different
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
fi

node -v > "$NODE_FILE" || {
    echo "Failed to save Node Version backup."
    exit 1
}

echo "Node.js version backed up successfully!"
echo "Saved version: $(cat "$NODE_FILE")"
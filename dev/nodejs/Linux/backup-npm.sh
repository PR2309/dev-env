#!/usr/bin/env sh

echo "Backing up NPM Version..."

# Check Node.js
if ! command -v node >/dev/null 2>&1; then
    echo "Node.js not found. Install Node.js first."
    exit 1
fi

# Check npm
if ! command -v npm >/dev/null 2>&1; then
    echo "npm not found. Fix Node.js installation."
    exit 1
fi

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Ensure Data directory exists
mkdir -p "$SCRIPT_DIR/../Data"

echo "Storing NPM Version..."

# Backup npm version
NPM_FILE="$SCRIPT_DIR/../Data/npm-version.txt"

# Get current npm version
CURRENT_VERSION=$(npm -v)

# Read existing version if file exists
if [ -f "$NPM_FILE" ]; then
    EXISTING_VERSION=$(tr -d '\n' < "$NPM_FILE")

    echo ""
    echo "⚠ Backup file already exists!"
    echo "Existing saved version : $EXISTING_VERSION"
    echo "New version to save    : $CURRENT_VERSION"
    echo ""

    # Skip if same version
    if [ "$CURRENT_VERSION" = "$EXISTING_VERSION" ]; then
        echo "npm is already at version $EXISTING_VERSION. No action needed."
        exit 0
    fi

    # Ask overwrite confirmation
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

npm -v > "$NPM_FILE" || {
    echo "Failed to save npm version backup."
    exit 1
}

echo "npm version saved successfully."
echo "Saved npm version: $(cat "$NPM_FILE")"
#!/usr/bin/env sh

echo "Backing up NPM Packages..."

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

echo "Storing NPM Packages..."

# Backup npm version
PKG_FILE_TEXT="$SCRIPT_DIR/../Data/global-npm-packages.txt"
PKG_FILE_JSON="$SCRIPT_DIR/../Data/global-packages.json"

if [ -f "$PKG_FILE_JSON" ] || [ -f "$PKG_FILE_TEXT" ]; then
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

echo "Backing up global npm packages. This may take a moment..."

# npm list -g --json > "$PKG_FILE_JSON"
# npm list -g --depth=0 > "$PKG_FILE_TEXT"

npm list -g --json > "$PKG_FILE_JSON" || {
    echo "Failed to save JSON backup."
    exit 1
}

npm list -g --depth=0 > "$PKG_FILE_TEXT" || {
    echo "Failed to save TEXT backup."
    exit 1
}

echo "Global npm packages backed up successfully!"
echo "JSON backup: $PKG_FILE_JSON"
echo "TEXT backup: $PKG_FILE_TEXT"

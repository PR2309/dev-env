#!/usr/bin/env sh

echo "Backing up Composer Version..."

# Check PHP
if ! command -v php >/dev/null 2>&1; then
    echo "PHP not found. Install PHP first."
    exit 1
fi

# Check Composer
if ! command -v composer >/dev/null 2>&1; then
    echo "Composer not found. Install Composer first."
    exit 1
fi

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Ensure Data directory exists
mkdir -p "$SCRIPT_DIR/../Data"

# File path
COMPOSER_FILE="$SCRIPT_DIR/../Data/composer-version.txt"

# Get current version (clean extraction)
CURRENT_VERSION=$(composer --version | awk '{print $3}' | tr -d ',')

# If file exists → compare first
if [ -f "$COMPOSER_FILE" ]; then
    EXISTING_VERSION=$(tr -d '\n' < "$COMPOSER_FILE")

    echo ""
    echo "⚠ Backup file already exists!"
    echo "Existing saved version : $EXISTING_VERSION"
    echo "New version to save    : $CURRENT_VERSION"
    echo ""

    # Skip if same
    if [ "$CURRENT_VERSION" = "$EXISTING_VERSION" ]; then
        echo "Composer is already at version $EXISTING_VERSION. No action needed."
        exit 0
    fi

    # Ask overwrite
    while true; do
        printf "Overwrite existing version? (yes/no): "
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

# Save version
echo "$CURRENT_VERSION" > "$COMPOSER_FILE"

# Verify write success
if [ $? -ne 0 ]; then
    echo "Failed to save Composer version."
    exit 1
fi

echo "Composer version backed up successfully!"
echo "Saved version: $(cat "$COMPOSER_FILE")"
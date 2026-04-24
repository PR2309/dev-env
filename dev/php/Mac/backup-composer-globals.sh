#!/usr/bin/env sh

echo "Backing up PHP Composer packages..."

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Ensure Data directory exists
mkdir -p "$SCRIPT_DIR/../Data"

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

# Define backup file paths
TEXT_FILE="$SCRIPT_DIR/../Data/global-composer-packages.txt"
JSON_FILE="$SCRIPT_DIR/../Data/global-composer-packages.json"

# If any file exists → ask once (better UX than asking twice)
if [ -f "$TEXT_FILE" ] || [ -f "$JSON_FILE" ]; then
    while true; do
        printf "Backup file exists. Overwrite? (yes/no): "
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

# Upgrade Composer first to ensure we get the latest package info and avoid potential issues with older versions
echo "⬆ Upgrading Composer..."
composer self-update || {
    echo "Failed to upgrade Composer."
    exit 1
}

# Save packages
echo "Storing PHP Composer packages..."
composer global show > "$TEXT_FILE" || {
    echo "Failed to save TEXT backup."
    exit 1
}

composer global show --format=json > "$JSON_FILE" || {
    echo "Failed to save JSON backup."
    exit 1
}

echo "PHP Composer environment backed up successfully!"
echo "Saved files:"
echo " - $TEXT_FILE"
echo " - $JSON_FILE"
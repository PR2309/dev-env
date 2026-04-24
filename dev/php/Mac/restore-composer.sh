# Make it executable before use:
# chmod +x dev/composer/restore-composer.sh

#!/usr/bin/env sh

echo "Restoring Composer Version..."

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

# Backup file
COMPOSER_FILE="$SCRIPT_DIR/../Data/composer-version.txt"

# Check if backup file exists
if [ ! -f "$COMPOSER_FILE" ]; then
    echo "Backup file not found: $COMPOSER_FILE"
    exit 1
fi

# Get current & stored Composer version
CURRENT_VERSION=$(composer --version | awk '{print $3}' | tr -d ',')
STORED_VERSION=$(tr -d '\n' < "$COMPOSER_FILE")

echo ""
echo "Current Composer version : $CURRENT_VERSION"
echo "Stored Composer version  : $STORED_VERSION"
echo ""

# Skip if same
if [ "$CURRENT_VERSION" = "$STORED_VERSION" ]; then
    echo "Composer is already at version $STORED_VERSION. No action needed."
    exit 0
fi

# Confirm switch
while true; do
    printf "Switch Composer version? (yes/no): "
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

# Restore Composer version
composer self-update "$STORED_VERSION"

if [ $? -ne 0 ]; then
    echo "Failed to restore Composer version."
    exit 1
fi

echo "Composer version restored successfully!"
echo "Current version: $(composer --version | awk '{print $3}' | tr -d ',')"
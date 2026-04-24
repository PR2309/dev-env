#!/usr/bin/env sh

echo "Restoring NPM Packages (from text backup)..."

# Go to script directory
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR" || exit 1

# Check Node
if ! command -v node >/dev/null 2>&1; then
    echo "Node.js is not installed."
    exit 1
fi

# Check NPM
if ! command -v npm >/dev/null 2>&1; then
    echo "npm is not installed."
    exit 1
fi

# File path
PACKAGES_FILE="../Data/global-npm-packages.txt"

# Check file exists
if [ ! -f "$PACKAGES_FILE" ]; then
    echo "Text backup file not found"
    exit 1
fi

installed=""
failed=""

# Process file line by line
while IFS= read -r line; do

    # Remove tree symbols and spaces
    pkg=$(echo "$line" | sed 's/^\(Γö£ΓöÇΓöÇ\|[[:space:]│├└─]\)*//' | xargs)

    # Skip empty lines
    [ -z "$pkg" ] && continue

    # Skip npm & node
    if [[ "$pkg" == npm@* || "$pkg" == node@* ]]; then
        continue
    fi

    # Skip invalid entries (no version)
    if ! echo "$pkg" | grep -q "@[0-9]"; then
        echo "Skipping invalid entry: $pkg"
        continue
    fi

    echo "Installing $pkg"
    npm install -g "$pkg"

    if [ $? -ne 0 ]; then
        failed="$failed\n$pkg"
    else
        installed="$installed\n$pkg"
    fi

done < "$PACKAGES_FILE"

echo "Global npm packages restored"

# Show failed packages
if [ -n "$failed" ]; then
    echo "\n❌ Failed packages:"
    printf "%b\n" "$failed"
fi

# Ask to show installed packages
while true; do
    printf "Do you want list of packages installed now? (yes/no): "
    read choice
    choice=$(echo "$choice" | tr '[:upper:]' '[:lower:]')

    if [ "$choice" = "yes" ] || [ "$choice" = "y" ]; then
        echo "\n✔ Installed packages:"
        printf "%b\n" "$installed"
        break
    elif [ "$choice" = "no" ] || [ "$choice" = "n" ]; then
        exit 0
    else
        echo "Invalid input. Enter yes/y or no/n."
    fi
done

# Show all current packages
while true; do
    printf "Do you want list of all installed packages? (yes/no): "
    read choice
    choice=$(echo "$choice" | tr '[:upper:]' '[:lower:]')

    if [ "$choice" = "yes" ] || [ "$choice" = "y" ]; then
        echo "\n📦 Current global packages:"
        npm list -g --depth=0
        break
    elif [ "$choice" = "no" ] || [ "$choice" = "n" ]; then
        exit 0
    else
        echo "Invalid input. Enter yes/y or no/n."
    fi
done
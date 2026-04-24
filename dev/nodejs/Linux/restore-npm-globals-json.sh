#!/usr/bin/env sh

echo "Restoring NPM Packages..."

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
    echo "npm is not installed. Install npm first."
    exit 1
fi

# File path
PACKAGES_PATH="../Data/global-packages.json"

# Check file exists
if [ ! -f "$PACKAGES_PATH" ]; then
    echo "global-packages.json not found"
    exit 1
fi

# Extract dependencies using node (no jq dependency)
DEPS=$(node -e "
const fs = require('fs');
const data = JSON.parse(fs.readFileSync('$PACKAGES_PATH', 'utf-8'));
const deps = data.dependencies || {};
for (const [name, info] of Object.entries(deps)) {
    if (name !== 'npm' && name !== 'node') {
        console.log(name + '@' + info.version);
    }
}
")

installed=""
failed=""

# Install packages
echo "$DEPS" | while IFS= read -r pkg; do
    echo "Installing $pkg"
    npm install -g "$pkg"

    if [ $? -ne 0 ]; then
        failed="$failed\n$pkg"
    else
        installed="$installed\n$pkg"
    fi
done

echo "Global npm packages restored"

# Show failed packages
if [ -n "$failed" ]; then
    echo "\nFailed packages:"
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

# Ask to show all global packages
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
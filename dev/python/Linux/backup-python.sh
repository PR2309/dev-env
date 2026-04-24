#!/usr/bin/env sh

echo "Backing up Python packages..."

# Check Python
if ! command -v python3 >/dev/null 2>&1; then
    echo "Python3 not found. Install Python first."
    exit 1
fi

# Check pip
if ! command -v pip3 >/dev/null 2>&1; then
    echo "pip3 not found. Fix Python installation."
    exit 1
fi

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# File paths
REQ_TEXT_FILE="$SCRIPT_DIR/../Data/requirements.txt"
REQ_JSON_FILE="$SCRIPT_DIR/../Data/requirements.json"

# Ensure Data directory exists
mkdir -p "$SCRIPT_DIR/../Data"

# Ask once if ANY file exists
if [ -f "$REQ_TEXT_FILE" ] || [ -f "$REQ_JSON_FILE" ]; then
    while true; do
        printf "Backup files exist. Overwrite? (yes/no): "
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

echo "⬆ Upgrading pip, setuptools, wheel..."
python3 -m pip install --upgrade pip setuptools wheel

echo "Storing Python packages..."

# Save TEXT (requirements.txt)
python3 -m pip freeze > "$REQ_TEXT_FILE"

if [ $? -ne 0 ]; then
    echo "Failed to save requirements.txt"
    exit 1
fi

# Save JSON (safe way — avoid pipe issues)
JSON_DATA=$(python3 -m pip list --format=json)

if [ $? -ne 0 ]; then
    echo "Failed to generate JSON data"
    exit 1
fi

echo "$JSON_DATA" > "$REQ_JSON_FILE"

if [ $? -ne 0 ]; then
    echo "Failed to save requirements.json"
    exit 1
fi

echo "Python environment backed up successfully!"
echo "Saved files:"
echo " - $REQ_TEXT_FILE"
echo " - $REQ_JSON_FILE"
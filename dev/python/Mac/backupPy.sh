#!/usr/bin/env sh

echo "Backing Up Python packages..."

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

echo "⬆ Upgrading pip, setuptools, wheel..."
python3 -m pip install --upgrade pip setuptools wheel

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REQ_FILE="$SCRIPT_DIR/../requirements.txt"

# Ask before overwrite (pro feature)
if [ -f "$REQ_FILE" ]; then
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

echo "Storeing Python packages..."
# pip freeze > ../requirements.txt
python3 -m pip freeze > "$REQ_FILE"

echo "Python environment backed up successfully!"

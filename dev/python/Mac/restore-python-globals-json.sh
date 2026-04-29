#!/usr/bin/env sh

echo "Restoring Python packages (from JSON)..."

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

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
JSON_FILE="$SCRIPT_DIR/../Data/requirements.json"

# Check JSON file
if [ ! -f "$JSON_FILE" ]; then
  echo "requirements.json not found at $JSON_FILE"
  exit 1
fi

FAILED=""

# Use python to parse JSON safely
python3 - <<EOF | while IFS= read -r pkg; do

import json

with open("$JSON_FILE", "r") as f:
    data = json.load(f)

for pkg in data:
    name = pkg.get("name")
    version = pkg.get("version")

    if name and version:
        print(f"{name}=={version}")
EOF

  # Skip empty
  [ -z "$pkg" ] && continue

  echo "Installing $pkg..."

  python3 -m pip install "$pkg"

  if [ $? -ne 0 ]; then
    echo "Failed: $pkg"
    FAILED="$FAILED\n$pkg"
  fi

done

# Print failed packages
echo "\nFailed Packages:"

if [ -z "$FAILED" ]; then
  echo "None"
else
  printf "$FAILED\n"
fi

echo "Python environment restored successfully!"
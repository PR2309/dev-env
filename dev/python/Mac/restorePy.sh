#!/usr/bin/env sh

echo "Restoring Python packages..."

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
REQ_FILE="$SCRIPT_DIR/../requirements.txt"

# Check requirements file
if [ ! -f "$REQ_FILE" ]; then
  echo "requirements.txt not found at $REQ_FILE"
  exit 1
fi

echo "Installing Python packages..."
# pip3 install -r "$REQ_FILE"

FAILED=""
# Read file line by line
while IFS= read -r pkg; do

  # Trim whitespace
  pkg="$(echo "$pkg" | xargs)"

  # Skip empty lines
  [ -z "$pkg" ] && continue

  echo "Installing $pkg..."

  python3 -m pip install "$pkg"

  # Check exit status
  if [ $? -ne 0 ]; then
    echo "Failed: $pkg"
    FAILED="$FAILED\n$pkg"
  fi

done < "$REQ_FILE"

# Print failed packages
echo "\nFailed Packages:"

if [ -z "$FAILED" ]; then
  echo "None 🎉"
else
  printf "$FAILED\n"
fi

echo "Python environment restored successfully!"

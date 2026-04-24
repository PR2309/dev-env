# Make it executable before use:
# chmod +x dev/composer/restore-composer.sh

#!/usr/bin/env sh

echo "Restoring Composer global packages (from TEXT)..."

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

echo "⬆ Updating Composer..."
composer self-update

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
TXT_FILE="$SCRIPT_DIR/../Data/global-composer-packages.txt"

# Check file
if [ ! -f "$TXT_FILE" ]; then
  echo "global-composer-packages.txt not found at $TXT_FILE"
  exit 1
fi

FAILED=""

# Read file line by line
while IFS= read -r line; do

  # Extract package name (first column)
  pkg=$(echo "$line" | awk '{print $1}')

  # Extract version (second column)
  ver=$(echo "$line" | awk '{print $2}')

  # Skip invalid lines
  echo "$pkg" | grep -q "/" || continue

  # Clean version (remove 'v')
  ver=$(echo "$ver" | sed 's/^v//')

  # If version exists → install exact
  if [ -n "$ver" ]; then
    full_pkg="$pkg:$ver"
  else
    full_pkg="$pkg"
  fi

  echo "➡ Installing $full_pkg"

  composer global require "$full_pkg"

  if [ $? -ne 0 ]; then
    echo "Failed: $full_pkg"
    FAILED="$FAILED\n$full_pkg"
  fi

done < "$TXT_FILE"

# Print failed packages
echo "\nFailed Packages:"

if [ -z "$FAILED" ]; then
  echo "None 🎉"
else
  printf "$FAILED\n"
fi

echo "Composer global packages restored successfully!"
# Make it executable before use:
# chmod +x dev/composer/restore-composer.sh

#!/usr/bin/env bash

set -e

FILE="global-composer-packages.txt"

if [ ! -f "$FILE" ]; then
  echo "❌ File not found: $FILE"
  exit 1
fi

echo "🔁 Restoring Composer global packages..."

grep -E '^[a-zA-Z0-9_.-]+/' "$FILE" | awk '{print $1}' | while read -r pkg; do
  echo "➡ Installing $pkg"
  composer global require "$pkg"
done

echo "✅ Composer global packages restored successfully"

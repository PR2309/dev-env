# Make it executable before use:
# chmod +x dev/composer/restore-composer.sh

#!/usr/bin/env sh

echo "Restoring Composer global packages (from JSON)..."

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
JSON_FILE="$SCRIPT_DIR/../Data/global-packages.json"

# Check JSON file
if [ ! -f "$JSON_FILE" ]; then
  echo "global-packages.json not found at $JSON_FILE"
  exit 1
fi

FAILED=""

# Use PHP to parse JSON safely (since Composer = PHP ecosystem)
php <<EOF | while IFS= read -r pkg; do
<?php
$data = json_decode(file_get_contents("$JSON_FILE"), true);

if (!isset($data['installed'])) {
    exit(0);
}

foreach ($data['installed'] as $pkg) {
    $name = $pkg['name'] ?? null;
    $version = $pkg['version'] ?? null;

    if ($name && $version) {
        // remove leading 'v' if present
        $version = ltrim($version, 'v');
        echo $name . ":" . $version . PHP_EOL;
    }
}
?>
EOF

  # Skip empty
  [ -z "$pkg" ] && continue

  echo "➡ Installing $pkg"

  composer global require "$pkg"

  if [ $? -ne 0 ]; then
    echo "Failed: $pkg"
    FAILED="$FAILED\n$pkg"
  fi

done

# Print failed packages
echo "\nFailed Packages:"

if [ -z "$FAILED" ]; then
  echo "None 🎉"
else
  printf "$FAILED\n"
fi

echo "Composer global packages restored successfully!"
#!/usr/bin/env bash

FILE="dev/npm/global-packages.json"

if [ ! -f "$FILE" ]; then
  echo "❌ global-packages.json not found"
  exit 1
fi

jq -r '.dependencies | to_entries[] | "\(.key)@\(.value.version)"' "$FILE" |
while read pkg; do
  name=$(echo "$pkg" | cut -d@ -f1)

  # Skip npm & node
  if [[ "$name" == "npm" || "$name" == "node" ]]; then
    continue
  fi

  echo "Installing $pkg"
  npm install -g "$pkg"
done

echo "✅ Global npm packages restored"

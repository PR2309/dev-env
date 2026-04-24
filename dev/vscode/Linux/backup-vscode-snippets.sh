#!/bin/bash

echo "Backing up VS Code Snippets (MERGE MODE)..."

# Go to script directory
cd "$(dirname "$0")"

# Source VS Code snippets folder
SOURCE_DIR="$APPDATA/Code/User/snippets"

# Destination backup folder
DEST_DIR="../Data/snippets"

# Check source exists
if [ ! -d "$SOURCE_DIR" ]; then
    echo "VS Code snippets folder not found!"
    exit 1
fi

# Ensure destination exists
mkdir -p "$DEST_DIR"

echo ""
echo "Using MERGE mode (no deletion of old files)"
echo ""

updated=0
added=0

# Loop through all snippet files
find "$SOURCE_DIR" -type f | while read -r file; do

    # Get relative path
    relative_path="${file#$SOURCE_DIR/}"
    target_file="$DEST_DIR/$relative_path"

    # Ensure target folder exists
    mkdir -p "$(dirname "$target_file")"

    if [ -f "$target_file" ]; then
        echo "↻ Updating: $relative_path"
        updated=$((updated + 1))
    else
        echo "＋ Adding: $relative_path"
        added=$((added + 1))
    fi

    # Copy file (overwrite or create)
    cp -f "$file" "$target_file"

done

echo ""
echo "========================"
echo "Snippets backup completed (MERGE MODE)!"
echo "========================"
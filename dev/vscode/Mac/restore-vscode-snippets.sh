#!/bin/bash

echo "Restoring VS Code Snippets (MERGE MODE)..."

# Go to script directory
cd "$(dirname "$0")"

# Source backup folder
SOURCE_DIR="../Data/snippets"

# Target VS Code snippets folder
TARGET_DIR="$APPDATA/Code/User/snippets"

# Check backup exists
if [ ! -d "$SOURCE_DIR" ]; then
    echo "Snippets backup folder not found!"
    exit 1
fi

# Ensure target exists
mkdir -p "$TARGET_DIR"

echo ""
echo "Using MERGE mode (no deletion of existing files)"
echo ""

updated=0
added=0

# Process all files
find "$SOURCE_DIR" -type f | while read -r file; do

    # Relative path
    relative_path="${file#$SOURCE_DIR/}"
    target_file="$TARGET_DIR/$relative_path"

    # Ensure subdirectory exists
    mkdir -p "$(dirname "$target_file")"

    if [ -f "$target_file" ]; then
        echo "↻ Updating: $relative_path"
        updated=$((updated + 1))
    else
        echo "＋ Adding: $relative_path"
        added=$((added + 1))
    fi

    # Copy (overwrite or create)
    cp -f "$file" "$target_file"

done

echo ""
echo "========================"
echo "Snippets restore completed (MERGE MODE)!"
echo "========================"
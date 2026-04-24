#!/bin/bash

echo "Checking VS Code Version..."

# Check VS Code
if ! command -v code >/dev/null 2>&1; then
    echo "VS Code not found. Install VS Code first."
    exit 1
fi

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Backup VS Code version
VSCODE_FILE="$SCRIPT_DIR/../Data/vscode-version.txt"

# Check if backup file exists
if [ ! -f "$VSCODE_FILE" ]; then
    echo "Backup file not found: $VSCODE_FILE"
    exit 1
fi

# Get current & Stored version
CURRENT_VERSION=$(code --version | head -n 1)
STORED_VERSION=$(tr -d '\n' < "$VSCODE_FILE")

echo ""
echo "Current VS Code version : $CURRENT_VERSION"
echo "Stored VS Code version  : $STORED_VERSION"
echo ""

# Check if matches
if [ "$CURRENT_VERSION" = "$STORED_VERSION" ]; then
    echo "VS Code is already at version $STORED_VERSION."
else
    echo "VS Code version does not match. Please install VS Code version $STORED_VERSION manually from https://code.visualstudio.com/download"
fi
#!/bin/bash
# =============================================================
# VS CODE RESTORE MENU
#
# USAGE:
#   Restore everything:
#     ./restore-vscode.sh
#
#   Restore only extensions:
#     ./restore-vscode.sh extensions
#
#   Restore only settings:
#     ./restore-vscode.sh settings
#
#   Restore only keybindings:
#     ./restore-vscode.sh keybindings
#
#   Restore only snippets:
#     ./restore-vscode.sh snippets
#
#   Restore multiple:
#     ./restore-vscode.sh extensions settings
#
# =============================================================

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

if [[ "$OSTYPE" == "darwin"* ]]; then
  VSCODE_USER_DIR="$HOME/Library/Application Support/Code/User"
  OS_NAME="macOS"
else
  VSCODE_USER_DIR="$HOME/.config/Code/User"
  OS_NAME="Linux"
fi

echo "Detected OS: $OS_NAME"
echo "VS Code User Dir: $VSCODE_USER_DIR"
echo "-------------------------------------"

# Default → restore all
if [ $# -eq 0 ]; then
  DO_EXT=true
  DO_SET=true
  DO_KEY=true
  DO_SNP=true
else
  DO_EXT=false
  DO_SET=false
  DO_KEY=false
  DO_SNP=false

  for arg in "$@"; do
    case $arg in
      extensions) DO_EXT=true ;;
      settings) DO_SET=true ;;
      keybindings) DO_KEY=true ;;
      snippets) DO_SNP=true ;;
    esac
  done
fi

mkdir -p "$VSCODE_USER_DIR/snippets"

if $DO_EXT; then
  echo "Restoring VS Code extensions..."
  while read -r ext; do
    code --install-extension "$ext"
  done < "$SCRIPT_DIR/extensions.txt"
fi

if $DO_SET; then
  echo "Restoring settings.json..."
  cp "$SCRIPT_DIR/settings.json" "$VSCODE_USER_DIR/settings.json"
fi

if $DO_KEY; then
  echo "Restoring keybindings.json..."
  cp "$SCRIPT_DIR/keybindings.json" "$VSCODE_USER_DIR/keybindings.json"
fi

if $DO_SNP; then
  echo "Restoring snippets..."
  cp -r "$SCRIPT_DIR/snippets/"* "$VSCODE_USER_DIR/snippets/"
fi

echo "✅ VS Code restore completed."

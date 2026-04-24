#!/usr/bin/env sh

echo "Restoring VS Code configuration..."

# Check VS Code
if ! command -v code >/dev/null 2>&1; then
    echo "VS Code not found. Install VS Code first."
    exit 1
fi

# Find the data folder dynamically (works from any location)
find_vscode_data_folder() {
    local current_path
    current_path="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    # First try: Check if we're already in a vscode folder
    if [[ "$(basename "$current_path")" == "vscode" ]]; then
        local data_path="$current_path/Data"
        if [[ -d "$data_path" ]]; then
            echo "$data_path"
            return 0
        fi
    fi

    # Second try: Check parent directory
    local parent_path
    parent_path="$(dirname "$current_path")"
    if [[ "$(basename "$parent_path")" == "vscode" ]]; then
        local data_path="$parent_path/Data"
        if [[ -d "$data_path" ]]; then
            echo "$data_path"
            return 0
        fi
    fi

    # Third try: Search for vscode folder in current directory and parents
    local search_path="$current_path"
    for ((i=0; i<5; i++)); do
        local vscode_path="$search_path/vscode"
        if [[ -d "$vscode_path" ]]; then
            local data_path="$vscode_path/Data"
            if [[ -d "$data_path" ]]; then
                echo "$data_path"
                return 0
            fi
        fi
        search_path="$(dirname "$search_path")"
        [[ "$search_path" == "/" ]] && break
    done

    # Last resort: Ask user
    echo "Could not automatically find vscode Data folder. Please specify the path to the vscode Data folder:" >&2
    read -r manual_path
    if [[ -d "$manual_path" ]]; then
        echo "$manual_path"
        return 0
    fi

    echo "VSCode Data folder not found. Please ensure the vscode Data folder exists." >&2
    return 1
}

DATA_ROOT=$(find_vscode_data_folder)
if [[ $? -ne 0 ]]; then
    exit 1
fi

# Determine VS Code user directory based on OS
if [[ "$OSTYPE" == "darwin"* ]]; then
    VSCODE_USER_DIR="$HOME/Library/Application Support/Code/User"
else
    VSCODE_USER_DIR="$HOME/.config/Code/User"
fi

EXT_FILE="$DATA_ROOT/extensions.txt"
SET_FILE="$DATA_ROOT/settings.json"
KEY_FILE="$DATA_ROOT/keybindings.json"
SNP_DIR="$DATA_ROOT/snippets"

# Check if backup files exist
files_exist=false
if [ -f "$EXT_FILE" ] || [ -f "$SET_FILE" ] || [ -f "$KEY_FILE" ] || [ -d "$SNP_DIR" ]; then
    files_exist=true
fi

if [ "$files_exist" = false ]; then
    echo "No backup files found in ../Data/ directory"
    exit 1
fi

while true; do
    printf "Do you want to restore VS Code configuration? (yes/no): "
    read choice
    choice=$(echo "$choice" | tr '[:upper:]' '[:lower:]')

    if [ "$choice" = "yes" ] || [ "$choice" = "y" ]; then
        break
    elif [ "$choice" = "no" ] || [ "$choice" = "n" ]; then
        echo "Cancelled."
        exit 0
    else
        echo "Invalid input. Please enter 'yes/y' or 'no/n'."
    fi
done

echo "Restoring VS Code configuration..."

# Restore extensions
if [ -f "$EXT_FILE" ]; then
    echo "Installing VS Code extensions..."
    failed_extensions=""
    while IFS= read -r ext; do
        [ -z "$ext" ] && continue
        echo "Installing $ext ..."
        if code --install-extension "$ext" >/dev/null 2>&1; then
            echo "✓ $ext"
        else
            echo "✗ Failed: $ext"
            failed_extensions="$failed_extensions$ext\n"
        fi
    done < "$EXT_FILE"

    if [ -n "$failed_extensions" ]; then
        echo -e "\nFailed Extensions:"
        echo -e "$failed_extensions"
    fi
fi

# Restore settings
if [ -f "$SET_FILE" ]; then
    echo "Restoring settings.json..."
    cp "$SET_FILE" "$VSCODE_USER_DIR/settings.json"
fi

# Restore keybindings
if [ -f "$KEY_FILE" ]; then
    echo "Restoring keybindings.json..."
    cp "$KEY_FILE" "$VSCODE_USER_DIR/keybindings.json"
fi

# Restore snippets
if [ -d "$SNP_DIR" ]; then
    echo "Restoring snippets..."
    mkdir -p "$VSCODE_USER_DIR/snippets"
    cp -r "$SNP_DIR"/* "$VSCODE_USER_DIR/snippets/" 2>/dev/null || true
fi

echo "VS Code configuration restored successfully!"

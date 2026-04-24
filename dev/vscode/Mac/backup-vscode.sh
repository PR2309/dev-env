#!/usr/bin/env sh

echo "Backing up VS Code configuration..."

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

echo "Storing VS Code configuration..."

# Backup extensions
EXT_FILE="$DATA_ROOT/extensions.txt"
if [ -f "$EXT_FILE" ]; then
    while true; do
        printf "File exists. Overwrite? (yes/no): "
        read choice
        choice=$(echo "$choice" | tr '[:upper:]' '[:lower:]')

        if [ "$choice" = "yes" ] || [ "$choice" = "y" ]; then
            break
        elif [ "$choice" = "no" ] || [ "$choice" = "n" ]; then
            echo "Cancelled."
            exit 0
        else
            echo "Invalid input. Enter yes/y or no/n."
        fi
    done
fi

code --list-extensions > "$EXT_FILE"

# Backup settings
SET_FILE="$DATA_ROOT/settings.json"
if [ -f "$SET_FILE" ]; then
    while true; do
        printf "File exists. Overwrite? (yes/no): "
        read choice
        choice=$(echo "$choice" | tr '[:upper:]' '[:lower:]')

        if [ "$choice" = "yes" ] || [ "$choice" = "y" ]; then
            break
        elif [ "$choice" = "no" ] || [ "$choice" = "n" ]; then
            echo "Cancelled."
            exit 0
        else
            echo "Invalid input. Enter yes/y or no/n."
        fi
    done
fi

cp "$VSCODE_USER_DIR/settings.json" "$SET_FILE"

# Backup keybindings
KEY_FILE="$DATA_ROOT/keybindings.json"
if [ -f "$KEY_FILE" ]; then
    while true; do
        printf "File exists. Overwrite? (yes/no): "
        read choice
        choice=$(echo "$choice" | tr '[:upper:]' '[:lower:]')

        if [ "$choice" = "yes" ] || [ "$choice" = "y" ]; then
            break
        elif [ "$choice" = "no" ] || [ "$choice" = "n" ]; then
            echo "Cancelled."
            exit 0
        else
            echo "Invalid input. Enter yes/y or no/n."
        fi
    done
fi

cp "$VSCODE_USER_DIR/keybindings.json" "$KEY_FILE"

# Backup snippets
SNP_DIR="$DATA_ROOT/snippets"
if [ -d "$SNP_DIR" ]; then
    while true; do
        printf "Snippets directory exists. Overwrite? (yes/no): "
        read choice
        choice=$(echo "$choice" | tr '[:upper:]' '[:lower:]')

        if [ "$choice" = "yes" ] || [ "$choice" = "y" ]; then
            break
        elif [ "$choice" = "no" ] || [ "$choice" = "n" ]; then
            echo "Cancelled."
            exit 0
        else
            echo "Invalid input. Enter yes/y or no/n."
        fi
    done
fi

# Remove existing snippets directory and copy new one
rm -rf "$SNP_DIR"
cp -r "$VSCODE_USER_DIR/snippets" "$SNP_DIR"

echo "VS Code configuration backed up successfully!"
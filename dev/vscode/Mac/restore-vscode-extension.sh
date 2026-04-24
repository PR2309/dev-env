#!/bin/bash

echo "Restoring VS Code Extensions..."

cd "$(dirname "$0")"

if ! command -v code &> /dev/null
then
    echo "VS Code is not installed or 'code' is not in PATH."
    exit 1
fi

EXTENSIONS_FILE="../Data/vscode-extensions.txt"

if [ ! -f "$EXTENSIONS_FILE" ]; then
    echo "Extensions backup file not found!"
    exit 1
fi

SUCCESS_LIST=()
FAILED_LIST=()

echo ""
echo "Installing extensions..."
echo ""

while IFS= read -r extension; do
    if [ -n "$extension" ]; then
        echo "→ Installing: $extension"

        code --install-extension "$extension"

        if [ $? -eq 0 ]; then
            echo "  ✔ Success"
            SUCCESS_LIST+=("$extension")
        else
            echo "  ✖ Failed"
            FAILED_LIST+=("$extension")
        fi

        echo ""
    fi
done < "$EXTENSIONS_FILE"

# SUMMARY
echo "========================"
echo "Restore completed!"
echo "Successful installs: ${#SUCCESS_LIST[@]}"
echo "Failed installs    : ${#FAILED_LIST[@]}"
echo "========================"

# SHOW FAILED DETAILS
if [ ${#FAILED_LIST[@]} -gt 0 ]; then
    echo ""
    echo " Failed Extensions:"
    for ext in "${FAILED_LIST[@]}"; do
        echo " - $ext"
    done
fi

# ASK USER FOR SUCCESS LIST
echo ""
read -p "Do you want to see successfully installed extensions? (yes/no): " choice
choice=$(echo "$choice" | tr '[:upper:]' '[:lower:]')

if [[ "$choice" == "yes" || "$choice" == "y" ]]; then
    echo ""
    echo "✔ Successfully Installed Extensions:"
    for ext in "${SUCCESS_LIST[@]}"; do
        echo " - $ext"
    done
else
    echo "Skipping success list display."
fi
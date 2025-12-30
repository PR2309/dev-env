#!/usr/bin/env sh

echo "🔁 Restoring Python packages..."

# Check Python
if ! command -v python3 >/dev/null 2>&1; then
  echo "❌ Python3 not found. Install Python first."
  exit 1
fi

# Check pip
if ! command -v pip3 >/dev/null 2>&1; then
  echo "❌ pip3 not found. Fix Python installation."
  exit 1
fi

echo "⬆ Upgrading pip, setuptools, wheel..."
python3 -m pip install --upgrade pip setuptools wheel

REQ_FILE="dev/python/requirements.txt"

if [ ! -f "$REQ_FILE" ]; then
  echo "❌ requirements.txt not found at $REQ_FILE"
  exit 1
fi

echo "📦 Installing Python packages..."
pip3 install -r "$REQ_FILE"

echo "✅ Python environment restored successfully!"

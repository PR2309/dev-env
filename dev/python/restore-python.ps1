Write-Host "🔁 Restoring Python packages..." -ForegroundColor Cyan

# Check Python
if (-not (Get-Command python -ErrorAction SilentlyContinue)) {
    Write-Error "❌ Python not found. Install Python first."
    exit 1
}

# Check pip
if (-not (Get-Command pip -ErrorAction SilentlyContinue)) {
    Write-Error "❌ pip not found. Fix Python installation."
    exit 1
}

Write-Host "⬆ Upgrading pip, setuptools, wheel..."
python -m pip install --upgrade pip setuptools wheel

$requirements = "dev/python/requirements.txt"

if (-not (Test-Path $requirements)) {
    Write-Error "❌ requirements.txt not found at $requirements"
    exit 1
}

Write-Host "📦 Installing Python packages..."
pip install -r $requirements

Write-Host "✅ Python environment restored successfully!" -ForegroundColor Green

#!/bin/bash
# offline-install.sh - Script to install MiniGoReg in an air-gapped environment

set -e

echo "🚀 Installing MiniGoReg in offline mode..."

# Check if we're in the scripts directory and adjust paths accordingly
if [[ $(basename $(pwd)) == "scripts" ]]; then
    ATHENS_IMAGE_PATH="../athens-image.tar"
    MODULES_ARCHIVE_PATH="../athens-modules.tar.gz"
else
    ATHENS_IMAGE_PATH="./athens-image.tar"
    MODULES_ARCHIVE_PATH="./athens-modules.tar.gz"
fi

# Allow overriding the paths via command line arguments
if [ -n "$1" ]; then
    ATHENS_IMAGE_PATH="$1"
fi

if [ -n "$2" ]; then
    MODULES_ARCHIVE_PATH="$2"
fi

# Check if files exist
if [ ! -f "$ATHENS_IMAGE_PATH" ]; then
    echo "❌ Error: Athens image file not found at $ATHENS_IMAGE_PATH"
    echo "Usage: ./offline-install.sh [path-to-athens-image.tar] [path-to-modules-archive.tar.gz]"
    exit 1
fi

if [ ! -f "$MODULES_ARCHIVE_PATH" ]; then
    echo "❌ Error: Modules archive not found at $MODULES_ARCHIVE_PATH"
    echo "Usage: ./offline-install.sh [path-to-athens-image.tar] [path-to-modules-archive.tar.gz]"
    exit 1
fi

# Step 1: Load the Athens container image
echo "📦 Loading Athens container image..."
podman load -i "$ATHENS_IMAGE_PATH"
echo "✅ Container image loaded"

# Step 2: Import modules
echo "📥 Importing modules..."
if [[ $(basename $(pwd)) == "scripts" ]]; then
    ./import-modules.sh "$MODULES_ARCHIVE_PATH"
else
    ./scripts/import-modules.sh "$MODULES_ARCHIVE_PATH"
fi
echo "✅ Modules imported"

# Step 3: Start Athens in offline mode
echo "🚀 Starting Athens proxy in offline mode..."
if [[ $(basename $(pwd)) == "scripts" ]]; then
    ./start-athens.sh offline
else
    ./scripts/start-athens.sh offline
fi
echo "✅ Athens proxy started in offline mode"

# Step 4: Verify installation
echo "🔍 Verifying installation..."
if curl -s http://localhost:3000/healthz > /dev/null; then
    echo "✅ Athens proxy is running correctly"
else
    echo "⚠️ Warning: Could not verify Athens proxy is running. Check with 'podman logs athens-proxy'"
fi

echo "✨ MiniGoReg offline installation complete!"
echo ""
echo "To use with Go, run: export GOPROXY=http://localhost:3000"
echo "To verify installation, run: curl http://localhost:3000/healthz"
echo "To check logs, run: podman logs athens-proxy"
echo ""
echo "Try it out with a test project:"
echo "  mkdir -p test-project && cd test-project"
echo "  go mod init test-project"
echo "  GOPROXY=http://localhost:3000 go get github.com/stretchr/testify"

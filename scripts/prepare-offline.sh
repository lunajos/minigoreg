#!/bin/bash
# prepare-offline.sh - Script to prepare MiniGoReg for offline installation
# This script prepares all necessary files for transfer to an air-gapped environment

set -e

# Configuration
ATHENS_IMAGE="gomods/athens:latest"
OUTPUT_DIR="./minigoreg-offline"
MODULE_LIST=${1:-"./sample-modules.txt"}

echo "🚀 Preparing MiniGoReg for offline installation..."

# Check if Athens is running, if not start it
if ! podman ps | grep -q athens-proxy; then
    echo "Starting Athens proxy..."
    ./scripts/start-athens.sh
    # Give Athens a moment to start up
    sleep 3
fi

# Check if module list exists
if [ ! -f "$MODULE_LIST" ]; then
    echo "❌ Error: Module list file '$MODULE_LIST' not found."
    echo "Usage: ./scripts/prepare-offline.sh [path-to-module-list]"
    exit 1
fi

# Create output directory
mkdir -p "$OUTPUT_DIR"

# Step 1: Pull and save Athens container image
echo "📦 Pulling and saving Athens container image..."
podman pull "$ATHENS_IMAGE"
podman save -o "$OUTPUT_DIR/athens-image.tar" "$ATHENS_IMAGE"
echo "✅ Container image saved to $OUTPUT_DIR/athens-image.tar"

# Step 2: Download modules
echo "📚 Downloading Go modules..."
./scripts/download-modules.sh "$MODULE_LIST"
echo "✅ Modules downloaded"

# Step 3: Export modules
echo "📤 Exporting modules..."
./scripts/export-modules.sh
# Move the exported archive to our output directory
mv athens-modules.tar.gz "$OUTPUT_DIR/"
echo "✅ Modules exported to $OUTPUT_DIR/athens-modules.tar.gz"

# Step 4: Copy necessary scripts and files
echo "📋 Copying scripts and configuration files..."
mkdir -p "$OUTPUT_DIR/scripts"
cp scripts/start-athens.sh "$OUTPUT_DIR/scripts/"
cp scripts/import-modules.sh "$OUTPUT_DIR/scripts/"
cp scripts/offline-install.sh "$OUTPUT_DIR/scripts/" 2>/dev/null || true
cp README.md "$OUTPUT_DIR/"
cp sample-modules.txt "$OUTPUT_DIR/"

# Step 5: Create the offline installation script if it doesn't exist
if [ ! -f "scripts/offline-install.sh" ]; then
    echo "📝 Creating offline installation script..."
    cat > "$OUTPUT_DIR/scripts/offline-install.sh" << 'EOF'
#!/bin/bash
# offline-install.sh - Script to install MiniGoReg in an air-gapped environment

set -e

echo "🚀 Installing MiniGoReg in offline mode..."

# Step 1: Load the Athens container image
echo "📦 Loading Athens container image..."
podman load -i ../athens-image.tar
echo "✅ Container image loaded"

# Step 2: Import modules
echo "📥 Importing modules..."
./import-modules.sh ../athens-modules.tar.gz
echo "✅ Modules imported"

# Step 3: Start Athens in offline mode
echo "🚀 Starting Athens proxy in offline mode..."
./start-athens.sh offline
echo "✅ Athens proxy started in offline mode"

echo "✨ MiniGoReg offline installation complete!"
echo "To use with Go, run: export GOPROXY=http://localhost:3000"
echo "To verify installation, run: curl http://localhost:3000/healthz"
EOF
    chmod +x "$OUTPUT_DIR/scripts/offline-install.sh"
    # Also copy to our scripts directory
    cp "$OUTPUT_DIR/scripts/offline-install.sh" scripts/
    chmod +x scripts/offline-install.sh
fi

# Make scripts executable
chmod +x "$OUTPUT_DIR/scripts/"*.sh

# Step 6: Create a single archive for easy transfer
echo "📦 Creating final package..."
tar -czf minigoreg-offline.tar.gz -C "$OUTPUT_DIR" .
echo "✅ Package created: minigoreg-offline.tar.gz"

echo "✨ Preparation complete! Transfer 'minigoreg-offline.tar.gz' to your air-gapped environment."
echo "Once transferred, extract and run: ./scripts/offline-install.sh"

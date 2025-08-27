#!/bin/bash
# Script to export Go modules from Athens proxy for transfer to air-gapped environment

set -e

EXPORT_DIR="./athens-export"
EXPORT_FILE="athens-modules.tar.gz"

# Check if Athens proxy is running
if ! curl -s http://localhost:3000/healthz > /dev/null; then
    echo "Error: Athens proxy is not running. Start it with './scripts/start-athens.sh'"
    exit 1
fi

# Create export directory if it doesn't exist
mkdir -p "$EXPORT_DIR"

echo "Exporting Athens modules to $EXPORT_DIR..."

# Copy the storage directory to the export directory
cp -r ./storage "$EXPORT_DIR/"

# Create a tarball of the export directory
tar -czf "$EXPORT_FILE" -C "$EXPORT_DIR" .

echo "✓ Modules exported to $EXPORT_FILE"
echo "Transfer this file to your air-gapped environment"

#!/bin/bash
# Script to import Go modules into Athens proxy in an air-gapped environment

set -e

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <modules-archive>"
    exit 1
fi

ARCHIVE_FILE=$1
IMPORT_DIR="./athens-import"

if [ ! -f "$ARCHIVE_FILE" ]; then
    echo "Error: Archive file '$ARCHIVE_FILE' not found"
    exit 1
fi

# Create import directory if it doesn't exist
mkdir -p "$IMPORT_DIR"

echo "Importing modules from $ARCHIVE_FILE..."

# Extract the archive to the import directory
tar -xzf "$ARCHIVE_FILE" -C "$IMPORT_DIR"

# Copy the storage directory to the current directory
if [ -d "$IMPORT_DIR/storage" ]; then
    echo "Copying module storage to current directory..."
    cp -r "$IMPORT_DIR/storage" ./
    echo "✓ Modules imported successfully"
    echo "Start Athens proxy in offline mode with 'podman-compose -f podman-compose.offline.yml up -d'"
else
    echo "Error: No storage directory found in the archive"
    exit 1
fi

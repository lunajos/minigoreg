#!/bin/bash
# Script to start Athens proxy using direct podman commands

set -e

# Default mode is online
MODE=${1:-online}
CONTAINER_NAME="athens-proxy"

# Check if container already exists
if podman container exists $CONTAINER_NAME; then
    echo "Container $CONTAINER_NAME already exists. Stopping and removing..."
    podman stop $CONTAINER_NAME || true
    podman rm $CONTAINER_NAME || true
fi

# Create storage directory if it doesn't exist
mkdir -p ./storage

if [ "$MODE" == "offline" ]; then
    echo "Starting Athens proxy in offline mode..."
    podman run -d \
        --name $CONTAINER_NAME \
        -p 3000:3000 \
        -v "$(pwd)/storage:/var/lib/athens:Z" \
        -e ATHENS_DISK_STORAGE_ROOT=/var/lib/athens \
        -e ATHENS_STORAGE_TYPE=disk \
        -e ATHENS_NETWORK_MODE=offline \
        -e ATHENS_DOWNLOAD_MODE=none \
        docker.io/gomods/athens:latest
else
    echo "Starting Athens proxy in online mode..."
    podman run -d \
        --name $CONTAINER_NAME \
        -p 3000:3000 \
        -v "$(pwd)/storage:/var/lib/athens:Z" \
        -e ATHENS_DISK_STORAGE_ROOT=/var/lib/athens \
        -e ATHENS_STORAGE_TYPE=disk \
        docker.io/gomods/athens:latest
fi

echo "Athens proxy is running at http://localhost:3000"
echo "To check status: podman logs $CONTAINER_NAME"
echo "To stop: podman stop $CONTAINER_NAME"

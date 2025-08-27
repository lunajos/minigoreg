#!/bin/bash
# Script to download Go modules using Athens proxy

set -e

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <module-list-file>"
    exit 1
fi

MODULE_LIST=$1

if [ ! -f "$MODULE_LIST" ]; then
    echo "Error: Module list file '$MODULE_LIST' not found"
    exit 1
fi

# Check if Athens proxy is running
if ! curl -s http://localhost:3000/healthz > /dev/null; then
    echo "Error: Athens proxy is not running. Start it with './scripts/start-athens.sh'"
    exit 1
fi

echo "Downloading modules from $MODULE_LIST..."

# Read each module from the file and download it
while IFS= read -r module || [ -n "$module" ]; do
    # Skip empty lines and comments
    if [[ -z "$module" || "$module" =~ ^# ]]; then
        continue
    fi
    
    echo "Downloading $module..."
    
    # Use go get with GOPROXY set to the local Athens instance
    GOPROXY=http://localhost:3000 go get -v "$module"
    
    echo "✓ Downloaded $module"
done < "$MODULE_LIST"

echo "All modules downloaded successfully!"

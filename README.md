# MiniGoReg - Self-Hosted Go Modules Registry for Air-Gapped Environments

This project provides a complete solution for hosting Go modules in air-gapped environments using Athens proxy. MiniGoReg makes it easy to download, export, and use Go modules without internet access.

## Overview

MiniGoReg solves the problem of managing Go modules in environments without internet access by:

1. Setting up an Athens proxy server in an internet-connected environment to download and cache modules
2. Transferring the cached modules to an air-gapped environment
3. Running Athens in offline mode in the air-gapped environment

## Prerequisites

- [Go](https://golang.org/dl/) (version 1.16 or later)
- [Podman](https://podman.io/getting-started/installation) (version 3.0 or later)
- Curl (for health checks)

## Getting Started

### Quick Start

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/minigoreg.git
   cd minigoreg
   ```

2. **Make scripts executable**
   ```bash
   chmod +x scripts/*.sh
   ```

3. **Start Athens proxy**
   ```bash
   ./scripts/start-athens.sh
   ```

4. **Download modules using the sample list**
   ```bash
   ./scripts/download-modules.sh sample-modules.txt
   ```

5. **Export modules for transfer**
   ```bash
   ./scripts/export-modules.sh
   ```
   This creates `athens-modules.tar.gz` which you can transfer to your air-gapped environment.

### Detailed Setup Guide

#### Internet-Connected Environment

1. **Prepare your module list**

   Create a text file listing the modules you need. Each line should contain a module path and optionally a version:
   ```
   github.com/example/module1@v1.2.3
   github.com/example/module2@latest
   ```
   
   You can use the provided `sample-modules.txt` as a starting point.

2. **Start Athens proxy**

   Start the Athens proxy server which will cache modules locally:
   ```bash
   ./scripts/start-athens.sh
   ```
   
   Verify it's running by visiting http://localhost:3000 in your browser.

3. **Download required modules**

   Use the download script to fetch and cache modules through Athens:
   ```bash
   ./scripts/download-modules.sh your-module-list.txt
   ```
   
   This will download all modules and their dependencies to the local Athens cache.

4. **Export modules for transfer**

   Package the cached modules for transfer to the air-gapped environment:
   ```bash
   ./scripts/export-modules.sh
   ```
   
   This creates `athens-modules.tar.gz` containing all downloaded modules.

#### Air-Gapped Environment

1. **Transfer the archive**

   Copy the `athens-modules.tar.gz` file to your air-gapped environment using physical media or approved transfer methods.

2. **Import modules**

   Extract the modules into the Athens storage directory:
   ```bash
   ./scripts/import-modules.sh athens-modules.tar.gz
   ```

3. **Start Athens proxy in offline mode**

   Start Athens configured to work without internet access:
   ```bash
   ./scripts/start-athens.sh offline
   ```

4. **Configure Go to use the local proxy**

   Set the GOPROXY environment variable to point to your local Athens instance:
   ```bash
   export GOPROXY=http://localhost:3000
   ```
   
   For permanent configuration, add this to your shell profile (~/.bashrc, ~/.zshrc, etc.).

5. **Use Go as normal**

   You can now use `go get`, `go build`, etc. as if you had internet access. Athens will serve modules from its local cache.

## Components

- `scripts/` - Helper scripts for managing the registry
  - `start-athens.sh` - Script to start Athens proxy using podman
  - `download-modules.sh` - Script to download modules from the internet
  - `export-modules.sh` - Script to export modules for transfer
  - `import-modules.sh` - Script to import modules in the air-gapped environment
- `sample-modules.txt` - Example module list to get started

## Troubleshooting

### Common Issues

1. **Athens proxy not starting**
   
   Check if the port is already in use:
   ```bash
   lsof -i :3000
   ```
   
   If another process is using port 3000, stop it or modify the port in `start-athens.sh`.

2. **Module not found in offline mode**

   Ensure the module was properly downloaded in the internet-connected environment:
   ```bash
   curl http://localhost:3000/github.com/your/module/@v/list
   ```
   
   If the module isn't listed, download it explicitly before exporting.

3. **Permission issues with storage directory**

   If you encounter permission errors, check the ownership of the storage directory:
   ```bash
   ls -la storage/
   ```
   
   You may need to adjust permissions or use `sudo` with the scripts.

### Checking Athens Status

To check if Athens is running properly:
```bash
curl http://localhost:3000/healthz
```

To view Athens logs:
```bash
podman logs athens-proxy
```

## Advanced Usage

### Adding Private Modules

To include private modules in your registry:

1. Authenticate with your private repository in the internet-connected environment
2. Add the private module paths to your module list
3. Follow the standard download and export process

### Updating Modules

To update your module cache with newer versions:

1. In the internet-connected environment, update your module list with new versions
2. Run the download script again
3. Export and transfer the updated modules
4. Import the new archive in the air-gapped environment

## Configuration

Athens proxy is configured through environment variables in the `start-athens.sh` script. Common settings include:

- `ATHENS_DISK_STORAGE_ROOT`: Location for storing modules
- `ATHENS_STORAGE_TYPE`: Storage backend type (disk, mongo, etc.)
- `ATHENS_NETWORK_MODE`: Network mode (offline for air-gapped environments)
- `ATHENS_DOWNLOAD_MODE`: Download behavior (none for offline mode)

For more configuration options, see the [Athens documentation](https://docs.gomods.io/).

## Complete Air-Gapped Deployment Guide

### Container Requirements

This solution uses the following container:
- **gomods/athens**: The Athens Go Module Proxy (version: latest or specific version like v0.11.0)

### Preparing for Air-Gapped Deployment

#### 1. Save the Container Image

In your internet-connected environment, pull and save the Athens container image:

```bash
# Pull the Athens image
podman pull gomods/athens:latest

# Save the image to a tar file
podman save -o athens-image.tar gomods/athens:latest
```

#### 2. Transfer Required Files

You'll need to transfer the following files to your air-gapped environment:

1. **Container image**: `athens-image.tar`
2. **Module cache**: `athens-modules.tar.gz` (created by export-modules.sh)
3. **Project files**: All scripts and configuration files

```bash
# Create a complete package for transfer
tar -czf minigoreg-airgap.tar.gz \
    athens-image.tar \
    athens-modules.tar.gz \
    scripts/ \
    README.md \
    sample-modules.txt
```

Transfer this package to your air-gapped environment using approved methods (physical media, approved file transfer, etc.).

### Setting Up in Air-Gapped Environment

#### 1. Extract the Transfer Package

```bash
tar -xzf minigoreg-airgap.tar.gz
```

#### 2. Load the Container Image

```bash
podman load -i athens-image.tar
```

Verify the image was loaded:
```bash
podman images | grep athens
```

#### 3. Import the Module Cache

```bash
./scripts/import-modules.sh athens-modules.tar.gz
```

#### 4. Start Athens in Offline Mode

```bash
./scripts/start-athens.sh offline
```

#### 5. Configure Go Environment

```bash
export GOPROXY=http://localhost:3000
```

Add this to your shell profile for persistence.

### Verifying the Setup

1. **Check Athens is running**:
   ```bash
   curl http://localhost:3000/healthz
   ```

2. **Test with a simple Go project**:
   ```bash
   mkdir -p test-project && cd test-project
   go mod init test-project
   # Try to get a module that was included in your cache
   go get github.com/stretchr/testify@v1.8.4
   ```

### Updating the Air-Gapped Environment

When you need to update your module cache with new modules or versions:

1. In the internet-connected environment:
   - Update your module list
   - Download new modules
   - Create a new export

2. Transfer the new module archive to the air-gapped environment

3. In the air-gapped environment:
   - Stop Athens: `podman stop athens-proxy`
   - Import the new modules
   - Restart Athens in offline mode

### Troubleshooting Air-Gapped Deployments

#### Missing Container Image

If you see an error like "image not found locally":

```bash
# Check if the image exists
podman images | grep athens

# If not, load it again
podman load -i athens-image.tar
```

#### Module Not Found

If a module is not found in the air-gapped environment:

1. Verify it was included in the export:
   ```bash
   find ./storage -name "*module-name*"
   ```

2. If not found, you'll need to:
   - Add it to your module list in the internet-connected environment
   - Download and create a new export
   - Transfer and import in the air-gapped environment

#### Container Networking Issues

If you can't connect to Athens on port 3000:

```bash
# Check if the container is running
podman ps | grep athens

# Check container logs
podman logs athens-proxy

# Restart the container if needed
./scripts/start-athens.sh offline
```

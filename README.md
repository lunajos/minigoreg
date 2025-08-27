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

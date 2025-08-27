# MiniGoReg - Self-Hosted Go Modules Registry for Air-Gapped Environments

This project provides a solution for hosting Go modules in air-gapped environments using Athens proxy.

## Overview

MiniGoReg solves the problem of managing Go modules in environments without internet access by:

1. Setting up an Athens proxy server in an internet-connected environment to download and cache modules
2. Transferring the cached modules to an air-gapped environment
3. Running Athens in offline mode in the air-gapped environment

## Components

- `podman-compose.yml` - Configuration for running Athens proxy
- `scripts/` - Helper scripts for managing the registry
  - `download-modules.sh` - Script to download modules from the internet
  - `export-modules.sh` - Script to export modules for transfer
  - `import-modules.sh` - Script to import modules in the air-gapped environment

## Usage

### Internet-Connected Environment

1. Start Athens proxy:
   ```
   podman-compose up -d
   ```

2. Download required modules:
   ```
   ./scripts/download-modules.sh <module-list-file>
   ```

3. Export modules for transfer:
   ```
   ./scripts/export-modules.sh
   ```

### Air-Gapped Environment

1. Import modules:
   ```
   ./scripts/import-modules.sh <modules-archive>
   ```

2. Start Athens proxy in offline mode:
   ```
   podman-compose -f podman-compose.offline.yml up -d
   ```

3. Configure Go to use the local proxy:
   ```
   export GOPROXY=http://localhost:3000
   ```

## Configuration

See the `config/` directory for Athens configuration options.

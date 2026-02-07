#!/bin/bash
# Node Exporter 1.10.2 Installation Script using local archive

set -e

NODE_EXPORTER_VERSION="1.10.2"

# Allow archive path to be passed as environment variable or use default
if [ -z "$LOCAL_ARCHIVE" ]; then
    LOCAL_ARCHIVE="/tmp/node_exporter-${NODE_EXPORTER_VERSION}.linux-arm64.tar.gz"
fi

INSTALL_DIR="/usr/local/node_exporter-${NODE_EXPORTER_VERSION}"

# Use temporary directory for extraction to avoid permission issues
TEMP_EXTRACT_DIR="/tmp/node_exporter_extract_$$"
mkdir -p $TEMP_EXTRACT_DIR

# Check if local archive exists
if [ ! -f "$LOCAL_ARCHIVE" ]; then
    echo "ERROR: Local archive not found at $LOCAL_ARCHIVE"
    echo "Please ensure the archive exists before running this script"
    exit 1
fi

echo "Using local Node Exporter archive: $LOCAL_ARCHIVE"
echo "Installing Node Exporter ${NODE_EXPORTER_VERSION}..."

echo "Extracting..."
tar -xvzf "$LOCAL_ARCHIVE" -C $TEMP_EXTRACT_DIR

# Create install directory
mkdir -p ${INSTALL_DIR}

echo "Installing to ${INSTALL_DIR}..."
# Move the extracted directory contents to the install directory
mv $TEMP_EXTRACT_DIR/node_exporter-${NODE_EXPORTER_VERSION}.linux-arm64/* ${INSTALL_DIR}/

# Clean up temporary extraction directory
rm -rf $TEMP_EXTRACT_DIR

echo "Creating symlink..."
ln -sf ${INSTALL_DIR} /usr/local/node_exporter

echo "Node Exporter ${NODE_EXPORTER_VERSION} installed successfully!"
echo "Binary location: /usr/local/node_exporter/node_exporter"
echo "Run with: /usr/local/node_exporter/node_exporter --web.listen-address=:9100"
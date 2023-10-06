#!/bin/bash

# Define the installation directory (a directory in the user's PATH)
INSTALL_DIR="/usr/local/bin"

# Determine the user's architecture
ARCH=$(uname -m)

# Check if the architecture is arm64
if [ "$ARCH" != "arm64" ]; then
  echo "Error: This installation script is for arm64 only."
  exit 1
fi

# URL of the pre-built Zig program binary
BINARY_URL="https://github.com/stitch-labs/stitch/releases/download/latest/stitch"

# Download the Zig program binary for arm64 from GitHub
curl -fsSL "$BINARY_URL" -o "$INSTALL_DIR/stitch"

# Check if the download was successful
if [ $? -ne 0 ]; then
  echo "Error: Failed to download the binary."
  exit 1
fi

# Make the Zig program executable
chmod +x "$INSTALL_DIR/stitch"

echo "stitch has been installed in $INSTALL_DIR"

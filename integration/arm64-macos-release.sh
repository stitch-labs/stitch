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

# Download the pre-built Zig program binary for arm64 from GitHub
BINARY_URL="https://github.com/stitch-labs/stitch/releases/latest/download/stitch-arm64"
curl -fsSL "$BINARY_URL" -o "$INSTALL_DIR/stitch"

# Check the HTTP status code
HTTP_STATUS=$?
if [ $HTTP_STATUS -ne 0 ]; then
  echo "Error: Failed to download the binary. HTTP status code: $HTTP_STATUS"
  exit 1
fi

# Make the Zig program executable
chmod +x "$INSTALL_DIR/stitch"

echo "stitch has been installed in $INSTALL_DIR"
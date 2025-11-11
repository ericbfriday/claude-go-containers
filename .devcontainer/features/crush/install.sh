#!/bin/bash
set -e

# Crush AI Coding Agent installation script
# This is an optional feature for the dev container

echo "Installing Crush AI Coding Agent..."

# Get version parameter (default to latest if not specified)
VERSION="${VERSION:-latest}"

# Install dependencies if not present
if ! command -v jq &> /dev/null; then
    apt-get update
    apt-get install -y jq
    rm -rf /var/lib/apt/lists/*
fi

# Determine version to install
if [ "$VERSION" = "latest" ]; then
    echo "Fetching latest Crush version..."
    CRUSH_VERSION=$(curl -s https://api.github.com/repos/charmbracelet/crush/releases/latest | jq -r '.tag_name' | sed 's/^v//')
else
    CRUSH_VERSION="$VERSION"
fi

echo "Installing Crush version: $CRUSH_VERSION"

# Download and install Crush binary
curl -fsSL "https://github.com/charmbracelet/crush/releases/latest/download/crush_${CRUSH_VERSION}_Linux_x86_64.tar.gz" -o /tmp/crush.tar.gz

# Extract and install
cd /tmp
tar -xzf crush.tar.gz
mv "crush_${CRUSH_VERSION}_Linux_x86_64/crush" /usr/local/bin/
chmod +x /usr/local/bin/crush

# Cleanup
rm -rf /tmp/crush.tar.gz "/tmp/crush_${CRUSH_VERSION}_Linux_x86_64"

# Also install via npm if node is available (provides additional integration)
if command -v npm &> /dev/null; then
    echo "Installing Crush npm package for enhanced integration..."
    npm install -g @charmland/crush
fi

echo "Crush AI Coding Agent installed successfully!"
crush --version

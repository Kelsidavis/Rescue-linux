#!/bin/bash
# AI Rescue Linux - ARM64 Build Script

set -e

echo "╔══════════════════════════════════════════════════════════════╗"
echo "║        AI Rescue Linux - ARM64 Build Script                 ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo "This script must be run as root (sudo)"
    exit 1
fi

# Check for qemu-user-static (needed for cross-building)
if ! command -v qemu-aarch64-static &> /dev/null; then
    echo "Installing QEMU for ARM64 cross-compilation..."
    apt-get update
    apt-get install -y qemu-user-static binfmt-support
fi

# Clean previous build
echo "Cleaning previous build..."
lb clean --purge 2>/dev/null || true

# Reconfigure for ARM64
echo "Configuring for ARM64..."
lb config \
  --distribution noble \
  --archive-areas "main restricted universe multiverse" \
  --architectures arm64 \
  --binary-images iso-hybrid \
  --debian-installer false \
  --mode ubuntu \
  --apt-recommends true \
  --memtest none \
  --bootstrap-qemu-arch arm64 \
  --bootstrap-qemu-static /usr/bin/qemu-aarch64-static \
  --iso-application "AI Rescue Linux ARM64" \
  --iso-publisher "AI Rescue Project" \
  --iso-volume "AI-RESCUE-ARM64"

# Build
echo ""
echo "Starting ARM64 build (this takes longer due to emulation)..."
lb build 2>&1 | tee build-arm64.log

if [ -f "live-image-arm64.hybrid.iso" ]; then
    echo ""
    echo "BUILD SUCCESSFUL!"
    mv live-image-arm64.hybrid.iso ai-rescue-linux-arm64.iso
    ls -lh ai-rescue-linux-arm64.iso
else
    echo "Build failed. Check build-arm64.log"
    exit 1
fi

#!/bin/bash
# AI Rescue Linux Build Script

set -e

echo "╔══════════════════════════════════════════════════════════════╗"
echo "║           AI Rescue Linux - Build Script                     ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo "This script must be run as root (sudo)"
    echo "Usage: sudo ./build.sh"
    exit 1
fi

# Check dependencies
echo "Checking dependencies..."
for cmd in lb debootstrap xorriso; do
    if ! command -v $cmd &> /dev/null; then
        echo "Missing: $cmd"
        echo "Install with: apt install live-build debootstrap xorriso"
        exit 1
    fi
done
echo "All dependencies found."
echo ""

# Clean previous build if exists
if [ -d "chroot" ] || [ -d ".build" ]; then
    echo "Cleaning previous build..."
    lb clean --purge
fi

# Build
echo ""
echo "Starting build process..."
echo "This will take 15-30 minutes depending on your internet speed."
echo ""

lb build 2>&1 | tee build.log

# Check result
if [ -f "live-image-amd64.hybrid.iso" ]; then
    echo ""
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║                    BUILD SUCCESSFUL!                         ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo ""
    ls -lh live-image-amd64.hybrid.iso
    echo ""
    echo "To write to USB drive:"
    echo "  sudo dd if=live-image-amd64.hybrid.iso of=/dev/sdX bs=4M status=progress"
    echo ""
    echo "Or use a tool like Balena Etcher or Ventoy."
else
    echo ""
    echo "Build may have failed. Check build.log for details."
fi

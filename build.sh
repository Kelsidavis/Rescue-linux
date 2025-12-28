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

# Check for configuration
CONFIG_DIR="config/includes.chroot/etc/ai-rescue"
if [ ! -f "$CONFIG_DIR/credentials.env" ]; then
    echo "═══════════════════════════════════════════════════════════════"
    echo "No API keys configured."
    echo ""
    echo "You can embed API keys so AI tools work immediately on boot."
    echo ""
    echo "Options:"
    echo "  1. Configure now (run ./configure.sh)"
    echo "  2. Build without embedded keys (users configure on boot)"
    echo ""
    read -p "Would you like to configure API keys now? [y/N]: " configure

    if [[ "$configure" =~ ^[Yy]$ ]]; then
        # Run configure as the original user, not root
        ORIGINAL_USER=${SUDO_USER:-$USER}
        echo ""
        echo "Running configuration..."
        sudo -u "$ORIGINAL_USER" ./configure.sh

        if [ ! -f "$CONFIG_DIR/credentials.env" ]; then
            echo "Configuration was cancelled or failed."
            read -p "Continue building without configuration? [y/N]: " cont
            if [[ ! "$cont" =~ ^[Yy]$ ]]; then
                echo "Build cancelled."
                exit 0
            fi
        fi
    fi
    echo ""
else
    echo "═══════════════════════════════════════════════════════════════"
    echo "Found existing configuration:"
    echo ""
    if grep -q "ANTHROPIC_API_KEY" "$CONFIG_DIR/credentials.env" 2>/dev/null; then
        echo "  ✓ Anthropic (Claude) API key"
    fi
    if grep -q "OPENAI_API_KEY" "$CONFIG_DIR/credentials.env" 2>/dev/null; then
        echo "  ✓ OpenAI API key"
    fi
    if grep -q "GOOGLE_API_KEY" "$CONFIG_DIR/credentials.env" 2>/dev/null; then
        echo "  ✓ Google (Gemini) API key"
    fi
    if grep -q "GITHUB_TOKEN" "$CONFIG_DIR/credentials.env" 2>/dev/null; then
        echo "  ✓ GitHub token"
    fi
    if [ -f "$CONFIG_DIR/custom-username" ]; then
        echo "  ✓ Custom user: $(cat "$CONFIG_DIR/custom-username")"
    fi
    if [ -f "$CONFIG_DIR/custom-timezone" ]; then
        echo "  ✓ Timezone: $(cat "$CONFIG_DIR/custom-timezone")"
    fi
    echo ""
    read -p "Use this configuration? [Y/n]: " use_config
    if [[ "$use_config" =~ ^[Nn]$ ]]; then
        echo "Run ./configure.sh to reconfigure, then run this script again."
        exit 0
    fi
    echo ""
fi

# Clean previous build if exists
if [ -d "chroot" ] || [ -d ".build" ]; then
    echo "Cleaning previous build..."
    lb clean --purge 2>/dev/null || true
fi

# Build
echo ""
echo "═══════════════════════════════════════════════════════════════"
echo "Starting build process..."
echo "This will take 15-30 minutes depending on your internet speed."
echo "═══════════════════════════════════════════════════════════════"
echo ""

lb build 2>&1 | tee build.log

# Check result
if [ -f "live-image-amd64.hybrid.iso" ]; then
    ISO_SIZE=$(du -h live-image-amd64.hybrid.iso | cut -f1)
    echo ""
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║                    BUILD SUCCESSFUL!                         ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo ""
    echo "  ISO: live-image-amd64.hybrid.iso"
    echo "  Size: $ISO_SIZE"
    echo ""
    echo "To write to USB drive:"
    echo "  sudo dd if=live-image-amd64.hybrid.iso of=/dev/sdX bs=4M status=progress"
    echo ""
    echo "Or use Balena Etcher or Ventoy."
    echo ""

    # Rename to something nicer
    mv live-image-amd64.hybrid.iso ai-rescue-linux.iso
    echo "Renamed to: ai-rescue-linux.iso"
else
    echo ""
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║                    BUILD FAILED                              ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo ""
    echo "Check build.log for details:"
    echo "  tail -100 build.log"
    echo ""
    exit 1
fi

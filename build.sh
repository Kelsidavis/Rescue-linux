#!/bin/bash
# AI Rescue Linux Build Script

set -e

echo "╔══════════════════════════════════════════════════════════════╗"
echo "║           AI Rescue Linux - Build Script                     ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""

# Parse arguments
CLEAN_ONLY=false
FORCE_CLEAN=false
SKIP_CONFIG=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --clean)
            CLEAN_ONLY=true
            shift
            ;;
        --force)
            FORCE_CLEAN=true
            shift
            ;;
        --skip-config)
            SKIP_CONFIG=true
            shift
            ;;
        -h|--help)
            echo "Usage: sudo ./build.sh [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --clean       Clean build artifacts only, don't build"
            echo "  --force       Force deep clean before building"
            echo "  --skip-config Skip configuration prompts"
            echo "  -h, --help    Show this help message"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo "This script must be run as root (sudo)"
    echo "Usage: sudo ./build.sh"
    exit 1
fi

# Function to clean stale mounts and locks
clean_stale_files() {
    echo "Cleaning stale files and mounts..."

    # Unmount any stale chroot mounts
    for mount_point in chroot/dev/pts chroot/proc chroot/sys chroot/dev; do
        if mountpoint -q "$mount_point" 2>/dev/null; then
            echo "  Unmounting $mount_point..."
            umount -lf "$mount_point" 2>/dev/null || true
        fi
    done

    # Remove lock files (but not directories named lock)
    find . -type f \( -name "lock" -o -name ".lock" \) 2>/dev/null | while read -r lockfile; do
        echo "  Removing lock file: $lockfile"
        rm -f "$lockfile"
    done
    rm -f .build/lock 2>/dev/null || true

    # Remove cached bootloader files that cause issues
    rm -rf chroot/root/isolinux* 2>/dev/null || true
    rm -rf chroot/binary 2>/dev/null || true

    # Remove stale binary directory contents that cause conflicts
    rm -rf binary/isolinux 2>/dev/null || true
    rm -rf binary/boot/grub 2>/dev/null || true

    echo "  Done."
}

# Check dependencies
echo "Checking dependencies..."
MISSING_DEPS=()
for cmd in lb debootstrap xorriso mksquashfs; do
    if ! command -v $cmd &> /dev/null; then
        MISSING_DEPS+=($cmd)
    fi
done

# Check for syslinux-utils (provides isohybrid)
if ! command -v isohybrid &> /dev/null; then
    MISSING_DEPS+=("syslinux-utils")
fi

if [ ${#MISSING_DEPS[@]} -gt 0 ]; then
    echo "Missing dependencies: ${MISSING_DEPS[*]}"
    echo "Install with: apt install live-build debootstrap xorriso squashfs-tools syslinux-utils"
    exit 1
fi
echo "All dependencies found."
echo ""

# Handle --clean option
if [ "$CLEAN_ONLY" = true ]; then
    echo "Performing full clean..."
    clean_stale_files
    lb clean --purge 2>/dev/null || true
    rm -f *.iso build.log 2>/dev/null || true
    echo ""
    echo "Clean complete."
    exit 0
fi

# Always clean stale files before building
clean_stale_files

# Force clean if requested
if [ "$FORCE_CLEAN" = true ]; then
    echo "Force cleaning previous build..."
    lb clean --purge 2>/dev/null || true
    echo ""
fi

# Check for configuration (skip if --skip-config)
CONFIG_DIR="config/includes.chroot/etc/ai-rescue"
if [ "$SKIP_CONFIG" = false ]; then
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
fi

# Clean previous build if exists and not already force-cleaned
if [ "$FORCE_CLEAN" = false ] && { [ -d "chroot" ] || [ -d ".build" ]; }; then
    echo "Found previous build artifacts."
    echo "Use --force to do a full clean rebuild, or continuing with incremental build..."
    echo ""
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

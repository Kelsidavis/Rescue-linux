# AI Rescue Linux

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Ubuntu Base](https://img.shields.io/badge/Base-Ubuntu%2024.04-orange.svg)](https://ubuntu.com)
[![AI Powered](https://img.shields.io/badge/AI-Claude%20%7C%20GPT%20%7C%20Gemini-blue.svg)](https://anthropic.com)

An AI-powered live Linux distribution designed for repairing and recovering broken Linux (and Windows) installations. Combines traditional rescue tools with modern AI assistants for guided troubleshooting.

![AI Rescue Linux Banner](docs/images/banner.png)

## Features

### AI-Powered Assistance
| Tool | Description |
|------|-------------|
| **Claude Code** | Anthropic's powerful CLI assistant for interactive repair guidance |
| **Aider** | AI pair programming for config file editing |
| **LLM CLI** | Multi-provider CLI (OpenAI, Anthropic, local models) |
| **Ollama** | Run local AI models offline (Llama, Mistral, etc.) |

### System Repair Tools
| Tool | Purpose |
|------|---------|
| **GParted** | Partition editing and management |
| **TestDisk/PhotoRec** | Partition and file recovery |
| **ddrescue** | Disk imaging for failing drives |
| **Boot Repair** | Automatic GRUB/bootloader repair |
| **fsck suite** | Filesystem repair (ext4, xfs, btrfs, ntfs) |
| **Sleuthkit** | Forensic analysis toolkit |
| **chntpw** | Windows password reset |

### AI-Assisted Helper Scripts
All helpers provide interactive, menu-driven interfaces:

| Command | Purpose |
|---------|---------|
| `ai-repair` | Launch AI assistant for guided repair |
| `ai-diagnose` | Generate comprehensive system diagnostics |
| `ai-chroot` | Auto-detect and chroot into broken systems |
| `ai-grub` | GRUB bootloader repair wizard |
| `ai-mount` | Interactive disk mounting |
| `ai-fstab` | Repair fstab entries |
| `ai-recover` | Data recovery wizard (TestDisk, PhotoRec, etc.) |
| `ai-clone` | Disk cloning/imaging (dd, ddrescue, partclone) |
| `ai-smart` | Disk health diagnostics |
| `ai-password` | Password reset for Linux/Windows |
| `ai-network` | Network diagnostics and configuration |

## Quick Start

### Download
Download the latest ISO from the [Releases](https://github.com/Kelsidavis/Rescue-linux/releases) page.

### Create Bootable USB

**Linux:**
```bash
sudo dd if=ai-rescue-linux.iso of=/dev/sdX bs=4M status=progress
```

**Windows:**
Use [Rufus](https://rufus.ie), [Balena Etcher](https://etcher.io), or [Ventoy](https://ventoy.net).

**macOS:**
```bash
sudo dd if=ai-rescue-linux.iso of=/dev/diskX bs=4m
```

### Boot Options
| Option | Description |
|--------|-------------|
| **Normal** | Full XFCE desktop with all tools |
| **Safe Mode** | Text mode, no GPU drivers |
| **To RAM** | Copy to RAM (faster, can remove USB) |
| **Forensic Mode** | Read-only, no disk writes |

### First Steps
1. Boot from USB
2. System auto-logs in as `rescue` user
3. Terminal opens with welcome screen
4. Run `setup-api-keys` to configure AI tools
5. Run `ai-repair` for guided assistance

## AI Setup

To use AI features, you need API keys (free tiers available):

| Provider | Get Key | Environment Variable |
|----------|---------|---------------------|
| Anthropic (Claude) | [console.anthropic.com](https://console.anthropic.com/) | `ANTHROPIC_API_KEY` |
| OpenAI | [platform.openai.com](https://platform.openai.com/api-keys) | `OPENAI_API_KEY` |
| Google (Gemini) | [aistudio.google.com](https://aistudio.google.com/apikey) | `GOOGLE_API_KEY` |

**Quick setup:**
```bash
# Interactive setup
setup-api-keys

# Or manually
export ANTHROPIC_API_KEY='sk-ant-...'
```

**Offline AI (no API key needed):**
```bash
/opt/ai-tools/install-ollama.sh
ollama pull llama2
ollama run llama2
```

## Common Use Cases

### Repair Broken GRUB
```bash
ai-grub
# Or manually:
ai-chroot
update-grub
grub-install /dev/sda
exit
```

### Recover Deleted Files
```bash
ai-recover
# Select recovery method:
# 1. TestDisk - lost partitions
# 2. PhotoRec - deleted files
# 3. extundelete - ext4 undelete
```

### Clone Failing Disk
```bash
ai-clone
# Select option 3: Rescue clone (ddrescue)
# This handles bad sectors gracefully
```

### Fix Broken Packages (Debian/Ubuntu)
```bash
ai-chroot
dpkg --configure -a
apt --fix-broken install
exit
```

### Reset Forgotten Password
```bash
ai-password
# Option 1: Linux password reset
# Option 2: Windows password reset (chntpw)
```

### Check Disk Health
```bash
ai-smart
# Shows SMART status for all drives
# Identifies failing disks before data loss
```

## Building from Source

### Requirements
- Ubuntu/Debian-based build system
- 10GB+ free disk space
- Internet connection
- `sudo` access

### Build Steps
```bash
# Clone repository
git clone https://github.com/Kelsidavis/Rescue-linux.git
cd ai-rescue-linux

# Install dependencies
sudo apt install live-build debootstrap xorriso isolinux syslinux-efi \
                 grub-pc-bin grub-efi-amd64-bin mtools squashfs-tools

# Build ISO
sudo ./build.sh
```

Build takes 15-30 minutes. Output: `live-image-amd64.hybrid.iso` (~3-4GB)

### Customization

**Add packages:** Edit files in `config/package-lists/`
```bash
config/package-lists/
├── desktop.list.chroot        # Desktop environment
├── dev-tools.list.chroot      # Development tools
├── network.list.chroot        # Network utilities
├── network-advanced.list.chroot
├── repair-tools.list.chroot   # Recovery tools
├── advanced-recovery.list.chroot
└── system.list.chroot         # System packages
```

**Add files:** Place in `config/includes.chroot/` with full path
```bash
# Example: add custom script
mkdir -p config/includes.chroot/usr/local/bin
echo '#!/bin/bash' > config/includes.chroot/usr/local/bin/my-script
chmod +x config/includes.chroot/usr/local/bin/my-script
```

**Add build hooks:** Create in `config/hooks/live/`
```bash
# Must be executable and end in .hook.chroot
config/hooks/live/0400-my-hook.hook.chroot
```

## Project Structure

```
ai-rescue-linux/
├── build.sh                          # Build script
├── README.md                         # This file
├── LICENSE                           # MIT License
├── CONTRIBUTING.md                   # Contribution guidelines
├── CHANGELOG.md                      # Version history
├── docs/                             # Documentation
│   ├── TOOLS.md                      # Tool reference
│   ├── TROUBLESHOOTING.md            # Common issues
│   └── images/                       # Screenshots
└── config/                           # live-build configuration
    ├── archives/                     # Additional repositories
    ├── hooks/live/                   # Build-time scripts
    │   ├── 0100-install-ai-tools.hook.chroot
    │   ├── 0200-configure-system.hook.chroot
    │   └── 0300-setup-desktop.hook.chroot
    ├── includes.chroot/              # Files included in ISO
    │   └── usr/local/bin/            # Helper scripts
    ├── includes.binary/              # Boot files
    └── package-lists/                # Package lists
```

## System Requirements

### Minimum
- 2GB RAM
- x86_64 CPU
- USB port or DVD drive

### Recommended
- 4GB+ RAM
- 64-bit CPU with virtualization
- USB 3.0 for faster boot
- Network connection for AI features

## FAQ

**Q: Do I need an internet connection?**
A: No, all repair tools work offline. AI features require internet unless using Ollama with local models.

**Q: Is my data safe?**
A: The live system runs entirely in RAM. Nothing is written to your disks unless you explicitly run a tool that does so. Use Forensic Mode for extra safety.

**Q: Can I install this permanently?**
A: This is designed as a live rescue system, not for permanent installation. For daily use, consider standard distributions.

**Q: Which AI should I use?**
A: Claude Code (Anthropic) is recommended for system repair tasks. It excels at understanding system logs and suggesting fixes.

**Q: Can I recover data from encrypted drives?**
A: Yes, if you know the passphrase. Tools like `cryptsetup` are included for LUKS, and the system supports eCryptfs.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

## License

This project is licensed under the MIT License - see [LICENSE](LICENSE) for details.

Individual packages included in the ISO retain their original licenses.

## Acknowledgments

- [Debian Live](https://www.debian.org/devel/debian-live/) - Build system
- [Anthropic](https://anthropic.com) - Claude AI
- [TestDisk](https://www.cgsecurity.org/testdisk) - Data recovery
- [GParted](https://gparted.org) - Partition editor
- All open source contributors

## Support

- [GitHub Issues](https://github.com/Kelsidavis/Rescue-linux/issues) - Bug reports and features
- [Discussions](https://github.com/Kelsidavis/Rescue-linux/discussions) - Questions and help

---

**Disclaimer:** This software is provided as-is. Always maintain backups of important data. The authors are not responsible for any data loss.

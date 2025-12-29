# Changelog

All notable changes to AI Rescue Linux will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- GitHub Actions CI/CD pipeline
  - Automated ISO builds on push/PR to main branch
  - Script linting with ShellCheck
  - Configuration validation checks
  - Security scanning for embedded secrets
  - Automated releases on version tags
  - ARM64 build workflow (manual trigger)
- CI status badges in README

## [1.0.0] - 2025-12-28

### Added
- Initial release of AI Rescue Linux
- Ubuntu 24.04 (Noble) base with XFCE desktop
- Auto-login as `rescue` user with passwordless sudo

#### AI Tools
- Claude Code (Anthropic) integration
- Aider AI pair programming
- LLM CLI (multi-provider)
- Ollama local AI support (install script)

#### Helper Scripts
- `ai-repair` - Interactive AI repair assistant
- `ai-diagnose` - System diagnostics generator
- `ai-chroot` - Auto-detect and chroot helper
- `ai-grub` - GRUB repair wizard
- `ai-mount` - Disk mounting helper
- `ai-fstab` - fstab repair tool
- `ai-recover` - Data recovery wizard
- `ai-clone` - Disk cloning assistant
- `ai-smart` - SMART disk health check
- `ai-password` - Linux/Windows password reset
- `ai-network` - Network diagnostics
- `ai-welcome` - Welcome screen
- `setup-api-keys` - API key configuration

#### Filesystem Tools
- ext2/3/4 tools (e2fsprogs)
- XFS tools (xfsprogs)
- Btrfs tools (btrfs-progs)
- NTFS support (ntfs-3g)
- ZFS support (zfsutils-linux)
- exFAT support (exfatprogs)
- F2FS support (f2fs-tools)

#### Recovery Tools
- TestDisk/PhotoRec
- ddrescue (gddrescue)
- foremost
- extundelete
- ext4magic
- scalpel
- Sleuthkit
- recoverjpeg
- magicrescue

#### Partition Tools
- GParted
- parted
- gdisk
- fdisk

#### Boot Repair
- GRUB2 (BIOS and UEFI)
- Boot Repair
- efibootmgr
- os-prober

#### Disk Tools
- SMART monitoring (smartmontools)
- hdparm, sdparm, nvme-cli
- partclone, fsarchiver
- LVM2, mdadm (RAID)
- cryptsetup (LUKS)

#### Network Tools
- NetworkManager with GUI
- SSH client and server
- rsync, rclone
- nmap, tcpdump
- OpenVPN, WireGuard
- iperf3, speedtest-cli

#### Desktop
- XFCE4 with taskbar
- Firefox browser
- Thunar file manager
- Terminal with custom prompt
- Desktop shortcuts for common tools

#### Boot Options
- Normal boot (full desktop)
- Safe mode (text, nomodeset)
- To RAM (toram)
- Forensic mode (read-only)

### Security
- Passwordless sudo for rescue user
- No persistent storage by default
- Forensic mode available

---

## Version History Format

### [X.Y.Z] - YYYY-MM-DD

#### Added
- New features

#### Changed
- Changes to existing features

#### Deprecated
- Features to be removed in future

#### Removed
- Removed features

#### Fixed
- Bug fixes

#### Security
- Security updates

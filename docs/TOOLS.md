# AI Rescue Linux - Tool Reference

Complete reference for all tools included in AI Rescue Linux.

## AI-Assisted Helpers

### ai-repair
Interactive AI repair assistant. Launches Claude Code for guided troubleshooting.

```bash
ai-repair
```

**Features:**
- Launches Claude Code if API key is set
- Falls back to other AI tools if available
- Provides menu of available AI assistants

---

### ai-diagnose
Generates comprehensive system diagnostics for AI analysis.

```bash
ai-diagnose
```

**Collects:**
- Block devices and partitions
- Disk usage and mounts
- Partition tables (all disks)
- SMART status
- Recent dmesg errors
- Journal errors
- Hardware information
- Network interfaces
- EFI boot entries

**Output:** `/tmp/system-diagnosis-YYYYMMDD-HHMMSS.txt`

---

### ai-chroot
Auto-detects Linux installations and sets up chroot environment.

```bash
ai-chroot
```

**Features:**
- Scans all partitions for Linux installations
- Shows distro name from /etc/os-release
- Mounts virtual filesystems (/dev, /proc, /sys, /run)
- Auto-mounts EFI partition if present
- Clean unmount on exit

---

### ai-grub
GRUB bootloader repair wizard.

```bash
ai-grub
```

**Options:**
1. Run ai-chroot and repair manually
2. Launch boot-repair GUI
3. Generate diagnostic for AI assistance

---

### ai-mount
Interactive disk mounting helper.

```bash
ai-mount
```

**Features:**
- Lists all available partitions
- Read-write or read-only mount options
- Auto-detects filesystem type
- Handles NTFS with ntfs-3g

---

### ai-fstab
fstab repair and validation tool.

```bash
ai-fstab
```

**Options:**
1. Validate fstab entries against actual UUIDs
2. Backup and edit fstab
3. Generate new fstab from current mounts
4. Export for AI analysis

---

### ai-recover
Data recovery wizard with multiple methods.

```bash
ai-recover
```

**Methods:**
1. TestDisk - Recover lost partitions
2. PhotoRec - Recover deleted files (any FS)
3. extundelete - Undelete from ext3/ext4
4. ext4magic - Advanced ext4 recovery
5. foremost - Carve files by headers
6. scalpel - Advanced file carving
7. recoverjpeg - Recover JPEG images
8. fatcat - FAT filesystem recovery

---

### ai-clone
Disk cloning and imaging assistant.

```bash
ai-clone
```

**Options:**
1. Clone disk to disk (dd)
2. Clone disk to image file
3. Rescue clone (ddrescue - for failing disks)
4. Partition clone (partclone)
5. Create compressed image (fsarchiver)

---

### ai-smart
SMART disk health diagnostics.

```bash
ai-smart
```

**Shows for each disk:**
- Model and serial number
- Overall health status (PASSED/FAILING)
- Key attributes:
  - Reallocated sectors
  - Pending sectors
  - Temperature
  - Power-on hours
  - Wear leveling (SSDs)

---

### ai-password
Password reset for Linux and Windows.

```bash
ai-password
```

**Options:**
1. Reset Linux user password (via chroot)
2. Reset/Remove Windows password (chntpw)
3. View Linux shadow file entries

---

### ai-network
Network diagnostics and configuration.

```bash
ai-network
```

**Shows:**
- Interface status
- Internet connectivity
- DNS resolution
- Gateway
- DNS servers

**Options:**
1. Configure WiFi (nmtui)
2. Configure wired connection
3. Set static IP
4. Run speed test
5. Scan local network
6. Test port connectivity

---

## Filesystem Tools

### Filesystem Check Commands
| Filesystem | Check Command | Repair Command |
|------------|---------------|----------------|
| ext2/3/4 | `fsck.ext4 -n /dev/sdX` | `fsck.ext4 -y /dev/sdX` |
| XFS | `xfs_repair -n /dev/sdX` | `xfs_repair /dev/sdX` |
| Btrfs | `btrfs check /dev/sdX` | `btrfs check --repair /dev/sdX` |
| NTFS | `ntfsfix /dev/sdX` | `ntfsfix /dev/sdX` |
| FAT | `fsck.vfat -n /dev/sdX` | `fsck.vfat -a /dev/sdX` |
| ZFS | `zpool status` | `zpool scrub poolname` |

### Partition Editors
| Tool | Type | Usage |
|------|------|-------|
| GParted | GUI | `gparted` |
| parted | CLI | `parted /dev/sdX` |
| gdisk | CLI (GPT) | `gdisk /dev/sdX` |
| fdisk | CLI (MBR) | `fdisk /dev/sdX` |
| cfdisk | TUI | `cfdisk /dev/sdX` |

---

## Data Recovery

### TestDisk
```bash
testdisk /dev/sdX
```
- Recover lost partitions
- Rebuild boot sector
- Fix partition tables

### PhotoRec
```bash
photorec /dev/sdX
```
- Recover deleted files
- Works on any filesystem
- Ignores filesystem structure

### ddrescue
```bash
ddrescue -d -r3 /dev/sdX output.img logfile.log
```
- Disk imaging for failing drives
- Handles bad sectors gracefully
- Resumable with log file

### Foremost
```bash
foremost -i /dev/sdX -o output_dir/
```
- Carve files by headers
- Supports many file types
- Works on disk images

---

## Boot Repair

### GRUB Reinstall
```bash
# Mount root partition
mount /dev/sdX /mnt
# Mount necessary filesystems
mount --bind /dev /mnt/dev
mount --bind /proc /mnt/proc
mount --bind /sys /mnt/sys
# Chroot
chroot /mnt
# Reinstall GRUB
grub-install /dev/sdX
update-grub
exit
umount -R /mnt
```

### EFI Boot Entries
```bash
# List entries
efibootmgr -v
# Create new entry
efibootmgr -c -d /dev/sdX -p 1 -L "Ubuntu" -l '\EFI\ubuntu\grubx64.efi'
# Delete entry
efibootmgr -b 0001 -B
```

### Boot Repair GUI
```bash
boot-repair
```
- Automatic GRUB repair
- Creates boot info summary
- Uploads diagnostic to pastebin

---

## Encryption

### LUKS
```bash
# Open encrypted volume
cryptsetup luksOpen /dev/sdX name
# Mount
mount /dev/mapper/name /mnt
# Close
umount /mnt
cryptsetup luksClose name
```

### eCryptfs
```bash
# Mount encrypted home
ecryptfs-recover-private
```

---

## LVM

```bash
# Scan for volume groups
vgscan
# Activate volume groups
vgchange -ay
# List logical volumes
lvs
# Mount
mount /dev/vgname/lvname /mnt
```

---

## RAID

### Software RAID (mdadm)
```bash
# Scan for arrays
mdadm --examine --scan
# Assemble arrays
mdadm --assemble --scan
# Check status
cat /proc/mdstat
```

### Hardware RAID (dmraid)
```bash
# Scan for RAID sets
dmraid -r
# Activate
dmraid -ay
```

---

## Network Tools

| Tool | Purpose | Example |
|------|---------|---------|
| nmtui | WiFi config TUI | `nmtui` |
| ip | Interface config | `ip addr` |
| ping | Connectivity test | `ping 8.8.8.8` |
| traceroute | Path tracing | `traceroute google.com` |
| nmap | Port scanning | `nmap -sn 192.168.1.0/24` |
| tcpdump | Packet capture | `tcpdump -i eth0` |
| ss | Socket stats | `ss -tuln` |
| dig | DNS lookup | `dig google.com` |
| curl | HTTP client | `curl -I https://example.com` |

---

## Disk Information

```bash
# List block devices
lsblk -f

# Detailed disk info
hdparm -I /dev/sdX

# SMART info
smartctl -a /dev/sdX

# Partition info
fdisk -l /dev/sdX

# Filesystem usage
df -h

# Inode usage
df -i
```

---

## Quick Reference

### Emergency Commands
```bash
# Force fsck on next boot (inside chroot)
touch /forcefsck

# Remount root read-write
mount -o remount,rw /

# Sync and emergency reboot
sync; reboot -f

# Kernel message buffer
dmesg | tail -100
```

### Dangerous Commands (use with care)
```bash
# Wipe partition table
wipefs -a /dev/sdX

# Zero disk (DESTROYS DATA)
dd if=/dev/zero of=/dev/sdX bs=1M

# Secure erase (DESTROYS DATA)
hdparm --security-erase NULL /dev/sdX
```

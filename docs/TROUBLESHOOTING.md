# AI Rescue Linux - Troubleshooting Guide

Common issues and solutions when using AI Rescue Linux.

## Boot Issues

### USB Won't Boot

**Symptoms:** Computer ignores USB or shows "No bootable device"

**Solutions:**
1. Check BIOS/UEFI boot order - USB should be first
2. Disable Secure Boot temporarily
3. Try different USB port (USB 2.0 often works better)
4. Recreate USB with different tool (try Rufus DD mode or Ventoy)
5. Verify ISO integrity: `sha256sum ai-rescue-linux.iso`

### Black Screen After Boot

**Symptoms:** System boots but screen stays black

**Solutions:**
1. Reboot and select "Safe Mode (No GUI)"
2. At GRUB menu, press `e` and add `nomodeset` to kernel line
3. Try different boot option (To RAM sometimes helps)

### Freezes During Boot

**Symptoms:** System hangs with kernel messages

**Solutions:**
1. Boot with "Safe Mode" option
2. Add `acpi=off` to kernel parameters
3. Try `noapic nolapic` kernel parameters
4. Check for hardware issues (RAM, disk)

---

## Hardware Detection

### Disk Not Showing

**Symptoms:** Expected disk not in `lsblk` output

**Solutions:**
```bash
# Rescan SCSI bus
echo "- - -" | sudo tee /sys/class/scsi_host/host*/scan

# Check dmesg for disk errors
dmesg | grep -i -E "(sd|nvme|ata|sata)"

# Check if disk is detected but not partitioned
cat /proc/partitions

# For USB drives, try replugging
```

### RAID Not Detected

**Symptoms:** RAID array not assembled

**Solutions:**
```bash
# Software RAID (mdadm)
mdadm --assemble --scan
cat /proc/mdstat

# Hardware/Fake RAID (dmraid)
dmraid -ay

# Check for degraded arrays
mdadm --detail /dev/md*
```

### NVMe Not Detected

**Symptoms:** NVMe SSD not showing

**Solutions:**
```bash
# List NVMe devices
nvme list

# Check if driver loaded
lsmod | grep nvme

# Load driver
modprobe nvme

# Check dmesg
dmesg | grep nvme
```

---

## Filesystem Issues

### Cannot Mount Filesystem

**Symptoms:** Mount fails with error

**Solutions:**
```bash
# Check filesystem type
blkid /dev/sdX1

# Try read-only mount first
mount -o ro /dev/sdX1 /mnt

# Force mount (dangerous)
mount -o force /dev/sdX1 /mnt

# For NTFS
mount -t ntfs-3g /dev/sdX1 /mnt

# If "already mounted" error
umount -l /mnt
```

### Filesystem Corruption

**Symptoms:** Errors about corrupt filesystem

**Solutions:**
```bash
# UNMOUNT FIRST!
umount /dev/sdX1

# ext4
fsck.ext4 -y /dev/sdX1

# XFS
xfs_repair /dev/sdX1

# Btrfs
btrfs check --repair /dev/sdX1

# NTFS
ntfsfix /dev/sdX1
```

### LVM Volumes Not Found

**Symptoms:** Logical volumes not appearing

**Solutions:**
```bash
# Scan for volume groups
vgscan

# Activate all volume groups
vgchange -ay

# List logical volumes
lvs

# If VG is inactive
vgchange -ay vgname
```

---

## Chroot Issues

### Chroot Fails

**Symptoms:** `chroot: failed to run command '/bin/bash'`

**Solutions:**
```bash
# Ensure target has bash
ls /mnt/bin/bash

# Mount required filesystems
mount --bind /dev /mnt/dev
mount --bind /dev/pts /mnt/dev/pts
mount --bind /proc /mnt/proc
mount --bind /sys /mnt/sys
mount --bind /run /mnt/run

# For different architecture (rare)
apt install qemu-user-static
cp /usr/bin/qemu-*-static /mnt/usr/bin/
```

### DNS Not Working in Chroot

**Symptoms:** Can't resolve hostnames inside chroot

**Solutions:**
```bash
# Copy resolv.conf
cp /etc/resolv.conf /mnt/etc/resolv.conf

# Or use Google DNS
echo "nameserver 8.8.8.8" > /mnt/etc/resolv.conf
```

### Package Manager Fails

**Symptoms:** apt/dpkg errors in chroot

**Solutions:**
```bash
# Inside chroot:

# Fix interrupted dpkg
dpkg --configure -a

# Fix broken dependencies
apt --fix-broken install

# Clear apt cache
apt clean

# Update package lists
apt update
```

---

## Boot Repair Issues

### GRUB Won't Install

**Symptoms:** grub-install fails

**Solutions:**
```bash
# Check target disk
lsblk

# For BIOS systems
grub-install --target=i386-pc /dev/sdX

# For UEFI systems (mount EFI partition first)
mount /dev/sdX1 /boot/efi
grub-install --target=x86_64-efi --efi-directory=/boot/efi

# Force install
grub-install --force /dev/sdX

# Recheck for bootloader
grub-install --recheck /dev/sdX
```

### update-grub Fails

**Symptoms:** Error generating grub.cfg

**Solutions:**
```bash
# Check os-prober
os-prober

# Enable os-prober (Ubuntu 22.04+)
echo 'GRUB_DISABLE_OS_PROBER=false' >> /etc/default/grub

# Regenerate config
update-grub

# Manual grub.cfg location
grub-mkconfig -o /boot/grub/grub.cfg
```

### EFI Boot Entry Missing

**Symptoms:** System doesn't show in UEFI boot menu

**Solutions:**
```bash
# List current entries
efibootmgr -v

# Create new entry
efibootmgr -c -d /dev/sdX -p 1 -L "Linux" -l '\EFI\ubuntu\grubx64.efi'

# Check EFI partition contents
ls -la /boot/efi/EFI/
```

---

## Network Issues

### No Network Connection

**Symptoms:** Cannot reach internet

**Solutions:**
```bash
# Check interface status
ip link

# Bring up interface
ip link set eth0 up

# Get DHCP address
dhclient eth0

# Check connectivity
ping 8.8.8.8
```

### WiFi Not Working

**Symptoms:** WiFi adapter not detected or won't connect

**Solutions:**
```bash
# Check if adapter detected
lspci | grep -i wireless
lsusb | grep -i wireless

# Check rfkill
rfkill list
rfkill unblock all

# Load driver
modprobe iwlwifi  # Intel
modprobe ath9k    # Atheros

# Use NetworkManager TUI
nmtui
```

### DNS Not Resolving

**Symptoms:** ping by IP works, hostname fails

**Solutions:**
```bash
# Test DNS
dig google.com

# Set DNS manually
echo "nameserver 8.8.8.8" > /etc/resolv.conf

# Or use NetworkManager
nmcli con mod "connection-name" ipv4.dns "8.8.8.8"
```

---

## AI Tool Issues

### Claude Code Not Working

**Symptoms:** `claude: command not found` or API errors

**Solutions:**
```bash
# Check if installed
which claude

# Check npm global packages
npm list -g

# Reinstall
npm install -g @anthropic-ai/claude-code

# Check API key
echo $ANTHROPIC_API_KEY

# Set API key
export ANTHROPIC_API_KEY='your-key-here'
```

### Ollama Installation Fails

**Symptoms:** Ollama install script fails

**Solutions:**
```bash
# Manual install
curl -fsSL https://ollama.ai/install.sh | sh

# Check systemd (live environment may not have it fully)
systemctl status ollama

# Run manually without systemd
ollama serve &
ollama pull llama2
```

---

## Build Issues

### Build Fails

**Symptoms:** `lb build` exits with error

**Solutions:**
```bash
# Clean and rebuild
sudo lb clean --purge
sudo lb build

# Check for package errors
grep -i error build.log
grep -i "unable to locate" build.log

# Verify package names exist
apt-cache show packagename

# Try with verbose output
sudo lb build --verbose
```

### Out of Disk Space

**Symptoms:** Build fails with space errors

**Solutions:**
```bash
# Check space
df -h

# Clean previous builds
sudo lb clean --purge

# Remove apt cache
sudo apt clean

# Need ~10GB free for build
```

---

## Quick Fixes

### Remount Root Read-Write
```bash
mount -o remount,rw /
```

### Force Kernel Panic Reboot
```bash
echo 1 > /proc/sys/kernel/sysrq
echo b > /proc/sysrq-trigger
```

### Check All Filesystems on Next Boot
```bash
touch /forcefsck
reboot
```

### Reset Failed Service
```bash
systemctl reset-failed
```

### Clear systemd Journal
```bash
journalctl --vacuum-size=100M
```

---

## Getting Help

1. Run `ai-diagnose` to generate diagnostic report
2. Use `ai-repair` for AI-guided troubleshooting
3. Check `dmesg` and `journalctl` for errors
4. Search error messages online
5. Open issue on GitHub with diagnostic report

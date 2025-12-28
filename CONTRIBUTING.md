# Contributing to AI Rescue Linux

Thank you for your interest in contributing! This document provides guidelines for contributing to AI Rescue Linux.

## Ways to Contribute

### Reporting Bugs
- Check existing [issues](https://github.com/Kelsidavis/Rescue-linux/issues) first
- Include your build environment (OS, live-build version)
- Provide steps to reproduce
- Attach relevant logs from `build.log`

### Suggesting Features
- Open a [discussion](https://github.com/Kelsidavis/Rescue-linux/discussions) first
- Explain the use case
- Consider if it fits the rescue/recovery focus

### Code Contributions
1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Make your changes
4. Test by building the ISO
5. Commit with clear messages
6. Push to your fork
7. Open a Pull Request

## Development Setup

### Prerequisites
```bash
# Ubuntu/Debian
sudo apt install live-build debootstrap xorriso isolinux syslinux-efi \
                 grub-pc-bin grub-efi-amd64-bin mtools squashfs-tools
```

### Building
```bash
git clone https://github.com/Kelsidavis/Rescue-linux.git
cd ai-rescue-linux
sudo ./build.sh
```

### Testing
- Boot the ISO in a VM (QEMU, VirtualBox, VMware)
- Test on real hardware if possible
- Verify both UEFI and BIOS boot modes

```bash
# Quick QEMU test
qemu-system-x86_64 -m 4G -enable-kvm -cdrom live-image-amd64.hybrid.iso
```

## Code Style

### Shell Scripts
- Use `#!/bin/bash` shebang
- Quote variables: `"$variable"`
- Use `[[ ]]` for tests
- Add comments for complex logic
- Make scripts executable: `chmod +x`

### Package Lists
- One package per line
- Group by category with comments
- Alphabetize within groups
- Test that packages exist in Ubuntu repos

### Hook Scripts
- Name format: `XXXX-description.hook.chroot`
- Lower numbers run first
- Use `set -e` for error handling
- Log progress with `echo`

## Adding New Tools

### Adding a Package
1. Identify the correct package list in `config/package-lists/`
2. Add the package name
3. Verify it exists: `apt-cache show packagename`
4. Rebuild and test

### Adding a Helper Script
1. Create script in `config/includes.chroot/usr/local/bin/`
2. Make it executable
3. Follow the `ai-*` naming convention
4. Add menu-driven interface
5. Update welcome message in `ai-welcome`
6. Document in README

### Adding a Desktop Shortcut
1. Create `.desktop` file in `config/includes.chroot/usr/share/applications/`
2. Follow freedesktop.org spec
3. Add to desktop in `0300-setup-desktop.hook.chroot`

## Pull Request Guidelines

### Before Submitting
- [ ] Code follows style guidelines
- [ ] ISO builds successfully
- [ ] Tested boot in VM
- [ ] Updated documentation if needed
- [ ] No sensitive data (API keys, passwords)

### PR Description
- Describe what the PR does
- Link related issues
- Note any breaking changes
- Include test results

### Review Process
1. Maintainer reviews code
2. CI builds ISO (if configured)
3. Feedback addressed
4. Merge when approved

## Commit Messages

Use clear, descriptive commit messages:

```
feat: add ZFS filesystem support

- Add zfsutils-linux to package list
- Include zfs-initramfs for boot support
- Update documentation

Closes #42
```

Prefixes:
- `feat:` - New feature
- `fix:` - Bug fix
- `docs:` - Documentation only
- `refactor:` - Code restructuring
- `chore:` - Maintenance tasks

## Questions?

- Open a [Discussion](https://github.com/Kelsidavis/Rescue-linux/discussions)
- Check existing documentation
- Review closed issues/PRs

## Code of Conduct

Be respectful and constructive. We're all here to help people recover their systems.

---

Thank you for contributing!

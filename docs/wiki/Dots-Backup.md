# 💾 Dots Backup Guide

The `dots backup` utility provides comprehensive backup and restoration capabilities for your dotfiles configuration. This tool helps you create snapshots, manage backup schedules, and restore previous configurations when needed.

> [!TIP]
> Regular backups are essential for maintaining system stability and recovering from configuration issues. The backup tool integrates seamlessly with chezmoi and your dotfiles workflow.

---

## 🚀 Usage

```sh
# Create a backup with default settings
dots backup

# List all available backups
dots backup --list

# Restore from a specific backup
dots backup --rollback

# Set up automated backups with cron
dots backup --register-cron

# Remove automated backups
dots backup --unregister-cron
```

### Advanced Options

```sh
# Custom backup location
dots backup --backup-dir=/path/to/custom/location

# Custom backup name
dots backup --backup-name=my-custom-backup

# Custom dotfiles directory (if not using default ~/.dotfiles)
dots backup --dotfiles-dir=/path/to/dotfiles

# Custom log file location
dots backup --log-file=/path/to/custom.log
```

---

## 📦 What Gets Backed Up

The backup tool creates comprehensive snapshots including:

- **Dotfiles source**: Your complete `~/.dotfiles` directory
- **Applied configurations**: Key config files from `~/.config`
- **Shell configurations**: `.zshrc`, `.bashrc`, `.profile`, etc.
- **SSH configurations**: `~/.ssh` directory (with permission preservation)
- **Git configurations**: `.gitconfig` and related files
- **Custom scripts**: `~/.local/bin` contents
- **Application data**: Selected application configurations

---

## 🔄 Automated Backups

### Setting Up Cron Jobs

```sh
# Register daily backups at 2 AM
dots backup --register-cron

# This creates a cron job that runs:
# 0 2 * * * /home/user/.local/bin/dots-backup --backup-name=daily_$(date +\%Y\%m\%d)
```

### Managing Automated Backups

```sh
# View current cron jobs
crontab -l

# Remove automated backups
dots backup --unregister-cron

# Check backup logs
tail -f ~/.cache/dots/backup.log
```

---

## 🔧 Backup Management

### Listing Backups

```sh
dots backup --list
```

This shows:

- Backup name and date
- Backup size
- Location on disk
- Backup integrity status

### Restoring from Backup

```sh
# Interactive restoration (shows available backups)
dots backup --rollback

# The restore process:
# 1. Lists available backups with timestamps
# 2. Allows you to select which backup to restore
# 3. Creates a pre-restore backup of current state
# 4. Restores selected backup
# 5. Runs chezmoi apply to sync changes
```

---

## 📁 Backup Structure

Default backup location: `~/.dotfiles/backup/`

```
backup/
├── dotfiles_backup_20250109_143022/
│   ├── dotfiles/          # Complete .dotfiles directory
│   ├── configs/           # Applied configurations
│   ├── ssh/              # SSH configurations (encrypted)
│   ├── scripts/          # Custom scripts
│   └── metadata.json     # Backup metadata and checksums
├── dotfiles_backup_20250108_140000/
└── ...
```

---

## 🛡️ Security Features

### Permission Preservation

- SSH keys maintain 600 permissions
- Directories preserve 700/755 permissions
- Sensitive files are properly secured

### Encryption Support

```sh
# Backup with GPG encryption (if gpg is configured)
dots backup --encrypt

# Restore encrypted backup
dots backup --rollback --decrypt
```

### Integrity Checking

- SHA256 checksums for all backed up files
- Automatic integrity verification during restore
- Corruption detection and reporting

---

## ⚙️ Configuration

### Default Settings

The backup tool uses these defaults:

- **Backup directory**: `~/.dotfiles/backup`
- **Backup name**: `dotfiles_backup_$(date)`
- **Log file**: `/tmp/dots_backup_log_$(date).txt`
- **Retention**: Keeps last 10 backups by default

### Customizing Backup Behavior

You can modify the backup script to:

- Change default retention policy
- Add/remove directories from backup scope
- Modify backup naming conventions
- Customize encryption settings

```sh
# Edit the backup script
chezmoi edit ~/.local/bin/executable_dots-backup
chezmoi apply
```

---

## 🆘 Troubleshooting

### Common Issues

**Permission Denied**

```sh
# Ensure proper permissions for backup directory
chmod 755 ~/.dotfiles/backup
```

**Large Backup Sizes**

```sh
# Exclude large files or directories by editing the script
# Add exclusions for cache directories, logs, etc.
```

**Failed Restores**

```sh
# Check backup integrity
dots backup --verify backup_name

# Manual restoration
cp -r ~/.dotfiles/backup/backup_name/dotfiles ~/.dotfiles-restored
```

### Recovery

If something goes wrong:

1. Current config is automatically backed up before any restore
2. Use `chezmoi diff` to see what changed
3. Use `chezmoi apply --dry-run` to preview changes
4. Restore from the automatic pre-restore backup if needed

---

## 💡 Best Practices

1. **Regular Backups**: Set up daily automated backups
2. **Test Restores**: Periodically test backup restoration
3. **Multiple Locations**: Consider backing up to external storage
4. **Version Control**: Use git for additional version tracking
5. **Documentation**: Document any custom backup configurations

---

## 🔗 Related Commands

- `chezmoi archive` - Create chezmoi-specific archives
- `dots config-manager` - Manage configuration snapshots
- `dots security-audit` - Audit backup security

The backup system works hand-in-hand with chezmoi to provide comprehensive configuration management and disaster recovery capabilities.

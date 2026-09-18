# 💾 Dots Backup Guide

> Retired wrapper: `dots-backup` was removed in #294. Backups are native:
> `horneroctl backup list|schedule|create|restore`. Tune with
> `HORNERO_BACKUP_DIR` (destination) and `HORNERO_BACKUP_SOURCE` (default `~/.dotfiles`).

The `horneroctl backup` verbs provide comprehensive backup and restoration capabilities for your dotfiles configuration. They create snapshots, print schedule recipes, and restore previous configurations when needed.

> [!TIP]
> Regular backups are essential for maintaining system stability and recovering from configuration issues. The backup tool integrates seamlessly with chezmoi and your dotfiles workflow.

---

## 🚀 Usage

```sh
# Create a backup with default settings
horneroctl backup create --yes

# List all available backups
horneroctl backup list

# Restore from a specific backup
horneroctl backup restore <id> --yes

# Print the cron/systemd schedule recipe (documented, not installed)
horneroctl backup schedule
```

### Advanced Options

```sh
# Custom backup location
HORNERO_BACKUP_DIR=/path/to/custom/location horneroctl backup create --yes

# Custom backup name
horneroctl backup create --name=my-custom-backup --yes

# Custom dotfiles directory (if not using default ~/.dotfiles)
HORNERO_BACKUP_SOURCE=/path/to/dotfiles horneroctl backup create --yes
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
# Print the daily-2AM cron recipe, then install it with crontab -e
horneroctl backup schedule

# The cron recipe runs:
# 0 2 * * * horneroctl backup create --yes
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

```text
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
# Backups are native (no script to edit); tune destination and source:
export HORNERO_BACKUP_DIR=/path/to/custom/location
export HORNERO_BACKUP_SOURCE=/path/to/dotfiles
horneroctl backup create --yes
```

---

## 🆘 Troubleshooting

### Common Issues

#### Permission Denied

```sh
# Ensure proper permissions for backup directory
chmod 755 ~/.dotfiles/backup
```

#### Large Backup Sizes

```sh
# Exclude large files or directories by editing the script
# Add exclusions for cache directories, logs, etc.
```

#### Failed Restores

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

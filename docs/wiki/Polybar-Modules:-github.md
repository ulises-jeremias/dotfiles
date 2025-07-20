# 📢 Polybar Module: GitHub Notifications

Stay updated with your GitHub notifications directly in your polybar status bar.

> [!TIP]
> The GitHub module displays unread notification count and integrates with GitHub's notification system to keep you informed about repository activity.

---

## 📋 Module Overview

The GitHub module provides:

- **Unread notification count** from your GitHub account
- **Real-time updates** every 10 seconds
- **Authentication** via personal access token
- **Clean integration** with system colors and fonts

---

## ⚙️ Configuration

### Basic Setup

```ini
[module/github]
type = internal/github

; Accessing an access token stored in file
token = ${file:~/.config/credentials/github_access_token_notifications}

; The github user for the token
user = your-username

; Whether empty notifications should be displayed or not
empty-notifications = false

; Number of seconds in between requests
interval = 10

; Available tags: <label> (default)
format = <label>

; Available tokens: %notifications% (default)
label = %{T4}󰊤%{T-} %notifications%
label-foreground = ${xrdb:color7}
```

### Configuration Options

| Property | Value | Description |
|----------|-------|-------------|
| `type` | `internal/github` | Built-in GitHub integration |
| `token` | `${file:~/.config/credentials/github_access_token_notifications}` | API token file path |
| `user` | `your-username` | GitHub username |
| `interval` | `10` | Update interval in seconds |
| `empty-notifications` | `false` | Show when no notifications |
| `api-url` | `https://api.github.com/` | GitHub API endpoint |

---

## 🔐 Authentication Setup

### Step 1: Create Personal Access Token

1. **Go to GitHub Settings**: [github.com/settings/tokens](https://github.com/settings/tokens)
2. **Generate new token** (classic)
3. **Select scopes**: `notifications` (read-only)
4. **Copy the token** (you won't see it again!)

### Step 2: Store Token Securely

```bash
# Create credentials directory
mkdir -p ~/.config/credentials
chmod 700 ~/.config/credentials

# Store token in file
echo "your_token_here" > ~/.config/credentials/github_access_token_notifications
chmod 600 ~/.config/credentials/github_access_token_notifications
```

### Step 3: Configure Username

The module template uses chezmoi templating:

```ini
; Template version (in github.conf.tmpl)
user = {{ .gitconfig.user.name }}

; Or set directly in generated file
user = your-github-username
```

---

## 🎨 Visual Appearance

### Default Display

```text
📢 3
```

### No Notifications

```text
📢 0
```

### Custom Styling

```ini
[module/github-styled]
type = internal/github
token = ${file:~/.config/credentials/github_access_token_notifications}
user = your-username
interval = 10

; Custom format with colors
format = <label>
label = %{F#4fc3f7}%{T4}📢%{T-}%{F-} %notifications%

; Hide when no notifications
empty-notifications = false
```

---

## 🔔 Notification States

### Different Visual States

```ini
[module/github-conditional]
type = internal/github
token = ${file:~/.config/credentials/github_access_token_notifications}
user = your-username
interval = 10

; Format for notifications
format = <label>
label = %{T4}📢%{T-} %notifications%
label-foreground = ${colors.foreground}

; Format when empty (if enabled)
format-empty = <label-empty>
label-empty = %{T4}📢%{T-} 0
label-empty-foreground = ${colors.foreground-alt}
```

### Click Actions

```ini
[module/github-clickable]
type = internal/github
token = ${file:~/.config/credentials/github_access_token_notifications}
user = your-username
interval = 10

format = <label>
label = %{A1:xdg-open https://github.com/notifications:}%{T4}📢%{T-} %notifications%%{A}

; Click to open GitHub notifications
click-left = xdg-open https://github.com/notifications
```

---

## 🚀 Advanced Configuration

### GitHub Enterprise

```ini
[module/github-enterprise]
type = internal/github
token = ${file:~/.config/credentials/github_enterprise_token}
user = your-username
interval = 10

; Custom API URL for GitHub Enterprise
api-url = https://your-github-enterprise.com/api/v3/

format = <label>
label = %{T4}🏢%{T-} %notifications%
```

### Multiple Accounts

```ini
; Personal account
[module/github-personal]
type = internal/github
token = ${file:~/.config/credentials/github_personal_token}
user = personal-username
interval = 15

; Work account  
[module/github-work]
type = internal/github
token = ${file:~/.config/credentials/github_work_token}
user = work-username
interval = 15
api-url = https://github-enterprise.company.com/api/v3/
```

### Smart Update Intervals

```ini
[module/github-smart]
type = internal/github
token = ${file:~/.config/credentials/github_access_token_notifications}
user = your-username

; More frequent updates during work hours
interval = 10

; Custom script wrapper for conditional intervals
type = custom/script
exec = ~/.config/polybar/configs/default/scripts/github-smart
interval = 30
```

Example smart script:

```bash
#!/usr/bin/env bash
# ~/.config/polybar/configs/default/scripts/github-smart

hour=$(date +%H)
day=$(date +%u)

# Work hours: update every 10 seconds
# Off hours: update every 5 minutes
if [ "$day" -le 5 ] && [ "$hour" -ge 9 ] && [ "$hour" -le 17 ]; then
    interval=10
else
    interval=300
fi

# Call actual GitHub API or use polybar's internal module
# Implementation depends on your needs
```

---

## 🔧 Usage Examples

### Minimal Notification Display

```ini
modules-right = github date
```

### Developer Status Bar

```ini
modules-right = github spotify cpu memory date
```

### Work-Focused Layout

```ini
# Top bar
modules-right = github network audio date

# Bottom bar  
modules-center = cpu memory filesystem
```

---

## 🛠️ Troubleshooting

### Common Issues

**No notifications showing**:

- Verify token file exists and is readable
- Check token permissions (needs `notifications` scope)
- Confirm username is correct
- Test API access manually:

```bash
# Test API access
curl -H "Authorization: token $(cat ~/.config/credentials/github_access_token_notifications)" \
     https://api.github.com/notifications
```

**Rate limiting**:

- Increase update interval to avoid hitting API limits
- GitHub API allows 5000 requests per hour for authenticated users

```ini
; Reduce API calls
interval = 60  ; Update every minute instead of 10 seconds
```

**Token authentication errors**:

```bash
# Check token file permissions
ls -la ~/.config/credentials/github_access_token_notifications

# Should show: -rw------- (600 permissions)
# If not, fix with:
chmod 600 ~/.config/credentials/github_access_token_notifications
```

### Debugging

```bash
# Test GitHub API manually
export TOKEN=$(cat ~/.config/credentials/github_access_token_notifications)
curl -H "Authorization: token $TOKEN" https://api.github.com/notifications

# Check polybar GitHub module
polybar-msg action github hook 0
```

---

## 🎨 Customization Ideas

### Priority-Based Styling

```ini
[module/github-priority]
type = custom/script
exec = ~/.config/polybar/configs/default/scripts/github-priority
interval = 30
```

Custom script for priority notifications:

```bash
#!/usr/bin/env bash
# ~/.config/polybar/configs/default/scripts/github-priority

token=$(cat ~/.config/credentials/github_access_token_notifications)
notifications=$(curl -s -H "Authorization: token $token" \
                https://api.github.com/notifications | jq length)

if [ "$notifications" -gt 10 ]; then
    echo "%{F#ff5555}%{T4}🚨%{T-}%{F-} $notifications"
elif [ "$notifications" -gt 5 ]; then
    echo "%{F#f5a70a}%{T4}⚠️%{T-}%{F-} $notifications"
elif [ "$notifications" -gt 0 ]; then
    echo "%{F#4fc3f7}%{T4}📢%{T-}%{F-} $notifications"
else
    echo "%{F#6c7086}%{T4}📢%{T-}%{F-} 0"
fi
```

### Repository-Specific Notifications

```ini
[module/github-repo]
type = custom/script
exec = ~/.config/polybar/configs/default/scripts/github-repo-notifications
interval = 60
```

### Integration with Git Status

```ini
[module/git-github]
type = custom/script
exec = ~/.config/polybar/configs/default/scripts/git-status-with-notifications
interval = 30
```

---

## 🔒 Security Considerations

### Token Management

- **Use minimal scopes**: Only grant `notifications` permission
- **Regular rotation**: Regenerate tokens periodically
- **Secure storage**: Keep token files with 600 permissions
- **Environment isolation**: Use different tokens for different environments

### Network Security

```ini
; Use HTTPS only (default)
api-url = https://api.github.com/

; For GitHub Enterprise, ensure HTTPS
api-url = https://your-github-enterprise.com/api/v3/
```

---

## ✅ Integration

### Works With

- ✅ **Personal GitHub accounts**
- ✅ **GitHub Enterprise** servers
- ✅ **Multiple accounts** (with separate modules)
- ✅ **All window managers** and bar configurations

### Pairs Well With

- **Git status modules** for complete development workflow
- **Spotify module** for coding session awareness  
- **System monitors** for development environment status

---

Stay connected to your GitHub workflow without leaving your desktop! 🚀

> [!TIP]
> Position the GitHub module prominently in your top bar if you're actively developing, or in the bottom bar for passive monitoring.

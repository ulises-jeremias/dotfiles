# 🛡️ Security Guide

While these dotfiles are designed to provide a beautiful and personalized setup, **privacy and security** are just as important. This is an evolving journey — not a one-time setup — and we’re always open to suggestions.

> [!TIP]
> You can tailor the security tools and settings to your preferences. All configurations can be automated or versioned using chezmoi where applicable.

---

## 🔒 Security Practices in Use

Here’s a list of tools and practices currently in place or under consideration:

### ✅ System Updates

- Regular updates are essential.
- I manually keep the system up-to-date using the package manager.

```sh
yay -Syyu  # [I use Arch, btw](https://wiki.archlinux.org/title/Arch_Linux)
```

> [!TIP]
> Consider automating this process with a cron job or alias.

### 🛡️ Malware Scanning

- [ClamAV](https://github.com/Cisco-Talos/clamav):
  - Run manual or scheduled scans
  - Keep virus database updated

```sh
sudo freshclam  # Update database
clamscan -r /home/youruser
```

### 🔥 Firewall

- [ufw](https://wiki.archlinux.org/title/Uncomplicated_Firewall): Simple firewall setup and management

```sh
sudo ufw enable
sudo ufw default deny incoming
sudo ufw allow out
```

### 🚫 IP Banning

- [fail2ban](https://github.com/fail2ban/fail2ban): Blocks IPs that show malicious behavior

```sh
sudo systemctl enable --now fail2ban
```

Check logs:

```sh
sudo fail2ban-client status
```

### 🔐 Password Management

- Currently using: [LastPass](https://www.lastpass.com/)
- Considering switching to: [Bitwarden](https://bitwarden.com/)

If self-hosting or CLI usage is preferred, Bitwarden offers [Bitwarden CLI](https://bitwarden.com/help/article/cli/).

### 🧬 Optional Hardening

- Hardened Linux Kernel (optional):
  - A stricter kernel for additional protections
  - Great for advanced users but may break things unexpectedly

> [!WARNING]
> Only recommended if you know your use cases won't be impacted.

### 🔎 Network & Port Scanning

- [nmap](https://github.com/nmap/nmap): Comprehensive network scanner
- [rustscan](https://github.com/RustScan/RustScan): Faster, modern alternative

```sh
sudo nmap -sS -p- 192.168.1.1
rustscan -a 192.168.1.1
```

Use for auditing your local network or spotting unknown open ports.

---

## 🧪 Tips for Staying Secure

- Use strong, unique passwords + 2FA where possible
- Don’t run random scripts without reading them first
- Use aliases to simplify safe commands (e.g., `update-all`)
- Consider using a VPN and encrypted DNS (like DoH or DoT)
- Keep regular backups in case of compromise

---

## 🆘 Need Help?

- [Arch Wiki on Security](https://wiki.archlinux.org/title/Security)
- [ClamAV Guide](https://docs.clamav.net/)
- [fail2ban GitHub](https://github.com/fail2ban/fail2ban)

Security is an ongoing practice — start with the basics, stay informed, and evolve over time 🔐

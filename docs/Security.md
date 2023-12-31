Although I like making it look as nice as possible, these dotfiles also try to be private and secure.
This is a journey, not a destination, and I am open to any input.

<details>

<summary>🛡️ Measures</summary>

</br>

- Manually keeping system up to date using the OS package manager. I use Arch btw so I run `yay -Syyu` every day.
- Malware scanning and database updating ([clamav](https://github.com/Cisco-Talos/clamav))
- Firewall ([ufw](https://wiki.archlinux.org/title/Uncomplicated_Firewall))
- Ban IPs ([fail2ban](https://github.com/fail2ban/fail2ban))
- Using [Signal](https://github.com/signalapp) (when possible)
- Hosting API keys in a private repo
- I could install the hardened Linux kernel, but that might be slightly pedantic...
- Port scanning ([nmap](https://github.com/nmap/nmap), [rustscan](https://github.com/RustScan/RustScan))

</details>

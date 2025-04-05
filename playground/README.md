# Development Playground

This playground provides a development environment using Vagrant with Docker Compose, running on Arch Linux. It's designed to provide a consistent and isolated development environment.

## Prerequisites

Before you begin, ensure you have the following installed:

1. Docker and Docker Compose
2. Vagrant
3. Vagrant plugins:

   ```bash
   vagrant plugin install vagrant-libvirt
   vagrant plugin install vagrant-disksize
   ```

4. libvirt and qemu
5. virt-manager (optional, for GUI management)

## Quick Start

The easiest way to manage the playground is using the `play` script located in the `bin` directory:

```bash
# Start the playground with default settings (i3 window manager)
./bin/play

# Start with a specific window manager
./bin/play --wm=plasma

# Provision the VM (re-run provisioning scripts)
./bin/play --provision

# Remove the VM
./bin/play --remove
```

The script automatically handles Docker Compose and Vagrant commands, and logs all output to a timestamped file in `/tmp/`.

## Manual Setup Instructions

If you prefer to run commands manually:

1. **Clone the repository** (if you haven't already):

   ```bash
   git clone <repository-url>
   cd <repository-name>/playground
   ```

2. **Start the Docker container**:

   ```bash
   docker compose up -d
   ```

3. **Initialize and start the Vagrant VM**:

   ```bash
   docker compose exec vagrant vagrant up
   ```

4. **Access the VM**:

   ```bash
   docker compose exec vagrant vagrant ssh
   ```

## Configuration Options

### Window Manager

You can choose between different window managers by setting the `WINDOW_MANAGER` environment variable or using the `--wm` option with the play script:

- `plasma` (default)
- `i3`
- `openbox`

Example:

```bash
# Using the play script
./bin/play --wm=i3

# Using environment variable
WINDOW_MANAGER=i3 docker compose up -d
```

### Login Manager

The default login manager is `sddm`. You can change it by setting the `PLAYGROUND_LOGIN_MANAGER` environment variable.

## VM Specifications

- Base OS: Arch Linux
- CPU: 4 cores
- Memory: 8GB
- Disk: 40GB (qcow2 format)
- Graphics: SPICE with QXL

## Testing the Setup

1. **Verify VM Status**:

   ```bash
   docker compose exec vagrant vagrant status
   ```

2. **Check VM Resources**:

   ```bash
   docker compose exec vagrant vagrant ssh -c "free -h && nproc"
   ```

3. **Test Window Manager**:
   After logging in, your chosen window manager should start automatically.

## Troubleshooting

1. **If Vagrant fails to start**:

   - Ensure libvirt service is running: `sudo systemctl start libvirtd`
   - Check libvirt permissions: `sudo usermod -a -G libvirt $USER`

2. **If Docker container fails**:

   - Check Docker logs: `docker compose logs`
   - Ensure Docker service is running: `sudo systemctl start docker`

3. **Graphics Issues**:

   - Install virt-viewer for better SPICE support: `sudo pacman -S virt-viewer`
   - Connect using: `virt-viewer --connect qemu:///system <vm-name>`

4. **Check Logs**:
   - The play script automatically logs all output to `/tmp/dots_playground_log_*.txt`
   - You can specify a custom log file: `./bin/play --log-file=/path/to/log.txt`

## Cleanup

To stop and remove the environment:

Using the play script:

```bash
./bin/play --remove
```

Or manually:

1. **Stop the Vagrant VM**:

   ```bash
   docker compose exec vagrant vagrant halt
   ```

2. **Remove the VM**:

   ```bash
   docker compose exec vagrant vagrant destroy -f
   ```

3. **Stop Docker containers**:

   ```bash
   docker compose down
   ```

## Additional Notes

- The VM uses SPICE for graphics, which provides better performance than VNC
- All provisioning scripts are in the `provision/` directory
- Configuration files are in the `config/` directory
- The VM is configured with 40GB of storage by default
- The environment uses host networking for better performance
- The `play` script provides a convenient way to manage the playground environment

For more information or issues, please refer to the main repository documentation or open an issue.

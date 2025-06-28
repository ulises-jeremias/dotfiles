# ADR-004: Testing Strategy with Docker/Vagrant

## Status

Accepted

## Context

HorneroConfig needs to be tested across different environments and configurations before deployment. Challenges include:

- **Multiple Distributions**: Support for Arch, Debian, Ubuntu, Alpine, etc.
- **Clean Environment Testing**: Avoid contaminating development machines
- **Window Manager Testing**: Visual components need graphical testing
- **Installation Testing**: Full installation process needs validation
- **Contributor Safety**: Contributors need safe environments for testing changes

Manual testing on production systems is risky and time-consuming. Virtual environments provide isolation and repeatability.

## Decision

We implemented a dual testing strategy using both Docker and Vagrant:

### Docker-based Testing (`playground/`)

- **Container Environment**: Lightweight testing for installation scripts
- **CI/CD Integration**: Automated testing in GitHub Actions
- **Quick Iteration**: Fast container startup for rapid testing cycles
- **Distribution Matrix**: Test across multiple Linux distributions

### Vagrant-based Testing (`bin/play`)

- **Full VM Environment**: Complete desktop environment testing
- **GUI Testing**: Window managers and visual components
- **Hardware Simulation**: More realistic system environment
- **Interactive Testing**: Manual testing with full desktop session

### Implementation Details

- `playground/compose.yml` - Docker Compose configuration
- `playground/Vagrantfile` - VM configuration with libvirt
- `bin/play` - Unified script for VM management
- Automated provisioning scripts for different environments

## Consequences

### Positive

- **Risk Mitigation**: Safe testing without affecting production systems
- **Reproducibility**: Consistent test environments across machines
- **CI/CD Integration**: Automated testing prevents regression
- **Multi-Distribution**: Easy testing across different Linux distributions
- **Contributor Confidence**: Safe environment encourages contributions

### Negative

- **Resource Usage**: VMs and containers consume system resources
- **Setup Complexity**: Additional tools (Docker, Vagrant) required
- **Maintenance Overhead**: Test environments need updates and maintenance
- **Performance**: Testing in VMs may not reflect bare metal performance

### Neutral

- **Tool Dependencies**: Requires Docker and/or Vagrant installation
- **Storage Requirements**: VM images and containers consume disk space
- **Network Configuration**: Some networking features may behave differently in VMs

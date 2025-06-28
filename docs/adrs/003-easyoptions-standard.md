# ADR-003: EasyOptions for Script Argument Parsing

## Status

Accepted

## Context

HorneroConfig includes dozens of utility scripts that need consistent command-line argument parsing. Requirements include:

- Standardized help system across all scripts
- Support for both short and long options
- Automatic documentation generation from script comments
- Consistent user experience across all utilities
- Minimal boilerplate code in individual scripts

Traditional bash argument parsing is verbose and error-prone, leading to inconsistent interfaces across scripts.

## Decision

We adopted the EasyOptions library for standardized argument parsing across all `dots-*` scripts.

EasyOptions provides:

- **Self-Documenting**: Help text generated from script comments
- **Dual Format Support**: Both `-h` and `--help` style options
- **Automatic Parsing**: Variables automatically populated from arguments
- **Consistent Interface**: Same argument handling across all scripts
- **Zero Dependencies**: Pure bash implementation

Implementation approach:

- All `dots-*` scripts source `~/.local/lib/dots/easy-options/easyoptions.sh`
- Help documentation written in special comment format at script top
- Options defined using `##` comment syntax
- Automatic variable assignment from parsed arguments

## Consequences

### Positive

- **Consistency**: All scripts have identical help and option handling
- **Documentation**: Help text is automatically generated and always up-to-date
- **Developer Experience**: Minimal boilerplate for new script creation
- **User Experience**: Predictable interface across all utilities
- **Maintainability**: Changes to option parsing affect all scripts uniformly

### Negative

- **Learning Curve**: Developers must learn EasyOptions comment syntax
- **Dependency**: All scripts depend on EasyOptions library
- **Limitations**: Advanced argument parsing features may be limited

### Neutral

- **File Size**: Small increase in script size due to sourcing
- **Performance**: Minimal parsing overhead for each script execution
- **Documentation Format**: Requires specific comment structure for help generation

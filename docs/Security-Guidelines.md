# Security Guidelines

## Security Philosophy

Security is built-in, not bolted-on:

- **Prevention**: Stop problems before they occur
- **Detection**: Identify security issues automatically
- **Response**: Provide clear remediation steps
- **Education**: Warn users about security implications

## Mandatory Security Practices

### 1. Secret Management

**Never commit secrets:**

- API tokens, passwords, API keys
- Private keys, certificates
- Personal information
- Authentication credentials

**Proper secret handling:**

```bash
# Use Chezmoi templates for secrets
{{ (bitwarden "item" "GitHub").password }}

# Or environment variables
GITHUB_TOKEN="${GITHUB_TOKEN:-}"
if [[ -z "$GITHUB_TOKEN" ]]; then
    log "ERROR" "GITHUB_TOKEN not set"
    exit 1
fi

# Or secure files with proper permissions
readonly TOKEN_FILE="$HOME/.config/private_credentials/github_token"
if [[ ! -f "$TOKEN_FILE" ]]; then
    log "ERROR" "Token file not found: $TOKEN_FILE"
    exit 1
fi
chmod 600 "$TOKEN_FILE"  # Ensure secure permissions
```

### 2. Input Validation

**Always validate user input:**

```bash
validate_input() {
    local input="$1"
    local type="$2"

    case "$type" in
        filename)
            # Prevent path traversal
            if [[ "$input" =~ \.\. ]] || [[ "$input" =~ / ]]; then
                log "ERROR" "Invalid filename: $input"
                return 1
            fi
            ;;
        number)
            # Ensure numeric
            if ! [[ "$input" =~ ^[0-9]+$ ]]; then
                log "ERROR" "Invalid number: $input"
                return 1
            fi
            ;;
        color)
            # Validate hex color
            if ! [[ "$input" =~ ^#[0-9A-Fa-f]{6}$ ]]; then
                log "ERROR" "Invalid color: $input"
                return 1
            fi
            ;;
    esac

    return 0
}
```

### 3. File Permissions

**Enforce correct permissions:**

```bash
# Private files (keys, credentials)
chmod 600 "$private_file"

# Executables
chmod 755 "$script_file"

# Directories
chmod 700 "$private_dir"
chmod 755 "$public_dir"

# Verify permissions
check_permissions() {
    local file="$1"
    local expected="$2"
    local actual
    actual=$(stat -c %a "$file")

    if [[ "$actual" != "$expected" ]]; then
        log "WARN" "Incorrect permissions on $file: $actual (expected $expected)"
        chmod "$expected" "$file"
    fi
}
```

### 4. Command Execution Safety

**Sanitize before executing:**

```bash
# Quote all variables
command "$variable"           # Correct
command $variable             # Wrong!

# Use arrays for complex commands
cmd_args=("--option" "value with spaces")
command "${cmd_args[@]}"

# Avoid eval when possible
# If you must use eval, validate thoroughly
eval "$(safe_command_generator)"  # Ensure generator is trustworthy
```

### 5. Temporary File Handling

**Use mktemp and cleanup:**

```bash
# Create secure temp file
temp_file=$(mktemp) || exit 1

# Ensure cleanup on exit
cleanup() {
    rm -f "$temp_file"
}
trap cleanup EXIT

# Use temp file
process_data > "$temp_file"
```

## Security Auditing

HorneroConfig includes built-in security auditing:

```bash
# Run complete security audit
dots security-audit

# Check specific aspects
dots security-audit --permissions
dots security-audit --secrets

# Apply automatic fixes
dots security-audit --fix

# Generate report
dots security-audit --report
```

**What it checks:**

- SSH key and config permissions
- Credential file security
- World-readable sensitive files
- Secrets in configuration files
- Shell history for sensitive data
- Firewall and system security settings

See [Security Guide](wiki/Security.md) for more details.

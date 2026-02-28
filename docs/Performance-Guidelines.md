# Performance Guidelines

## Performance Philosophy

Performance matters for user experience:

- Scripts should start quickly (< 1 second for most)
- UI updates should feel instant (< 100ms)
- Background tasks shouldn't impact system responsiveness
- Cache expensive operations to avoid recomputation

## Optimization Strategies

### 1. Lazy Loading

**Load only what's needed:**

```bash
# Bad: Load everything upfront
source ~/.local/lib/dots/all-libraries.sh

# Good: Load on demand
load_library() {
    local lib="$1"
    if [[ ! -v LOADED_LIBS["$lib"] ]]; then
        source "$HOME/.local/lib/dots/${lib}.sh"
        LOADED_LIBS["$lib"]=1
    fi
}
```

### 2. Caching Strategy

**Cache expensive operations:**

```bash
CACHE_DIR="$HOME/.cache/dots"
CACHE_TTL=3600  # 1 hour

get_cached() {
    local cache_key="$1"
    local cache_file="$CACHE_DIR/$cache_key"

    if [[ -f "$cache_file" ]]; then
        local age=$(( $(date +%s) - $(stat -c %Y "$cache_file") ))
        if [[ $age -lt $CACHE_TTL ]]; then
            cat "$cache_file"
            return 0
        fi
    fi

    return 1
}

set_cached() {
    local cache_key="$1"
    local content="$2"
    local cache_file="$CACHE_DIR/$cache_key"

    mkdir -p "$CACHE_DIR"
    echo "$content" > "$cache_file"
}
```

### 3. Parallel Execution

**When operations are independent:**

```bash
# Sequential (slow)
update_module_a
update_module_b
update_module_c

# Parallel (fast)
update_module_a &
update_module_b &
update_module_c &
wait
```

### 4. Timeout Mechanisms

**Prevent hanging:**

```bash
run_with_timeout() {
    local timeout="$1"
    shift
    local command=("$@")

    timeout "$timeout" "${command[@]}" || {
        local exit_code=$?
        if [[ $exit_code -eq 124 ]]; then
            log "WARN" "Command timed out after ${timeout}s: ${command[*]}"
        fi
        return $exit_code
    }
}

# Usage
run_with_timeout 5 curl "https://api.example.com/data"
```

### 5. Resource Cleanup

**Prevent resource leaks:**

```bash
# Trap ensures cleanup even on error
cleanup_resources() {
    # Close file descriptors
    exec 3>&- 2>/dev/null

    # Kill background processes
    local jobs
    jobs=$(jobs -p)
    [[ -n "$jobs" ]] && kill "$jobs" 2>/dev/null

    # Remove temp files
    rm -f /tmp/script-$$-*
}

trap cleanup_resources EXIT INT TERM
```

## Performance Best Practices

- **Minimize external commands** - Use bash built-ins when possible
- **Avoid subshells** - Use bash features instead of piping to external tools
- **Cache file operations** - Don't repeatedly read the same file
- **Use efficient data structures** - Arrays over loops of greps
- **Profile slow scripts** - Use `time` and `set -x` to find bottlenecks
- **Batch operations** - Group multiple operations together
- **Async where possible** - Don't block on slow operations

## Example: Smart Colors Caching

The smart colors system demonstrates good caching:

1. **Generate once**: Colors analyzed from wallpaper
2. **Cache multiple formats**: Quickshell scheme, Hyprland, shell
3. **Invalidate on change**: New wallpaper triggers regeneration
4. **Fast reads**: Applications read pre-generated files
5. **No recomputation**: Same colors used across all apps

Result: Sub-second theme switching for entire desktop.

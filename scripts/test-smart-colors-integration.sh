#!/usr/bin/env bash

## Test script for Smart Colors integration
## Verifies that all components work correctly with the new centralized system

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

show_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

show_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

show_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

show_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Test 1: Check if dots-smart-colors exists and is executable
test_smart_colors_command() {
    show_info "Testing dots-smart-colors command..."

    if command -v dots-smart-colors >/dev/null 2>&1; then
        show_success "dots-smart-colors command found"

        # Test help
        if dots-smart-colors --help >/dev/null 2>&1; then
            show_success "dots-smart-colors --help works"
        else
            show_error "dots-smart-colors --help failed"
            return 1
        fi

        # Test generate
        if dots-smart-colors --generate >/dev/null 2>&1; then
            show_success "dots-smart-colors --generate works"
        else
            show_error "dots-smart-colors --generate failed"
            return 1
        fi
    else
        show_error "dots-smart-colors command not found"
        return 1
    fi
}

# Test 2: Check if smart color files are generated
test_smart_color_files() {
    show_info "Testing smart color file generation..."

    local smart_colors_dir="$HOME/.cache/dots/smart-colors"
    local expected_files=(
        "colors-i3.conf"
        "colors-eww.scss"
        "colors.sh"
        "colors.env"
    )

    if [[ ! -d "$smart_colors_dir" ]]; then
        show_error "Smart colors directory not found: $smart_colors_dir"
        return 1
    fi

    for file in "${expected_files[@]}"; do
        local filepath="$smart_colors_dir/$file"
        if [[ -f "$filepath" ]]; then
            show_success "Found: $file"

            # Check if file has content
            if [[ -s "$filepath" ]]; then
                show_success "$file has content"
            else
                show_warning "$file is empty"
            fi
        else
            show_error "Missing: $file"
        fi
    done
}

# Test 3: Check if symbolic links are created
test_symbolic_links() {
    show_info "Testing symbolic links..."

    local links=(
        "$HOME/.config/i3/config.d/smart-colors.conf"
        "$HOME/.config/eww/dashboard/smart-colors.scss"
        "$HOME/.config/eww/powermenu/smart-colors.scss"
    )

    for link in "${links[@]}"; do
        if [[ -L "$link" ]]; then
            show_success "Symbolic link exists: $link"

            # Check if link target exists
            if [[ -f "$link" ]]; then
                show_success "Link target is valid: $link"
            else
                show_error "Link target is broken: $link"
            fi
        else
            show_error "Symbolic link missing: $link"
        fi
    done
}

# Test 4: Check i3 configuration syntax
test_i3_config() {
    show_info "Testing i3 configuration syntax..."

    if command -v i3 >/dev/null 2>&1; then
        if i3 -C -c "$HOME/.config/i3/config" >/dev/null 2>&1; then
            show_success "i3 configuration syntax is valid"
        else
            show_error "i3 configuration has syntax errors"
            show_info "Run 'i3 -C -c ~/.config/i3/config' for details"
            return 1
        fi
    else
        show_warning "i3 command not found, skipping syntax check"
    fi
}

# Test 5: Check EWW configuration syntax
test_eww_config() {
    show_info "Testing EWW configuration syntax..."

    if command -v eww >/dev/null 2>&1; then
        # Test dashboard
        if eww reload --config "$HOME/.config/eww/dashboard" >/dev/null 2>&1; then
            show_success "EWW dashboard configuration is valid"
        else
            show_warning "EWW dashboard configuration may have issues"
        fi

        # Test powermenu
        if eww reload --config "$HOME/.config/eww/powermenu" >/dev/null 2>&1; then
            show_success "EWW powermenu configuration is valid"
        else
            show_warning "EWW powermenu configuration may have issues"
        fi
    else
        show_warning "eww command not found, skipping syntax check"
    fi
}

# Test 6: Check Polybar integration
test_polybar_integration() {
    show_info "Testing Polybar integration..."

    local smart_colors_env="$HOME/.cache/dots/smart-colors/colors.env"

    if [[ -f "$smart_colors_env" ]]; then
        show_success "Smart colors environment file exists"

        # Check if environment variables are properly formatted
        if grep -q "export SMART_COLOR_" "$smart_colors_env"; then
            show_success "Environment variables are properly formatted"
        else
            show_error "Environment variables format is incorrect"
        fi
    else
        show_error "Smart colors environment file missing"
    fi
}

# Main test execution
main() {
    echo "=================================="
    echo "Smart Colors Integration Test"
    echo "=================================="
    echo

    local tests_passed=0
    local tests_total=6

    # Run all tests
    if test_smart_colors_command; then ((tests_passed++)); fi
    echo

    if test_smart_color_files; then ((tests_passed++)); fi
    echo

    if test_symbolic_links; then ((tests_passed++)); fi
    echo

    if test_i3_config; then ((tests_passed++)); fi
    echo

    if test_eww_config; then ((tests_passed++)); fi
    echo

    if test_polybar_integration; then ((tests_passed++)); fi
    echo

    # Summary
    echo "=================================="
    echo "Test Results: $tests_passed/$tests_total passed"
    echo "=================================="

    if [[ $tests_passed -eq $tests_total ]]; then
        show_success "All tests passed! Smart colors integration is working correctly."
        return 0
    else
        show_warning "Some tests failed. Check the output above for details."
        return 1
    fi
}

main "$@"

# Architecture Philosophy

## The Hornero Bird Principle

HorneroConfig is named after the hornero bird, which builds robust, functional nests adapted to their environment. This metaphor guides all development:

1. **Robustness**: Systems must handle edge cases gracefully
2. **Functionality**: Every component serves a clear purpose
3. **Adaptability**: Configurations adjust to different environments
4. **Beauty**: Aesthetic excellence without sacrificing utility
5. **Modularity**: Components work independently yet integrate seamlessly

## Core Design Principles

### 1. Theme-Adaptive Intelligence

All visual components must adapt to different color palettes and brightness levels without manual configuration.

**Key Concepts:**

- Automatic light/dark theme detection
- Semantic color mapping (error, success, warning, info)
- Contrast optimization for readability
- Fallback strategies for limited palettes

### 2. Modular Architecture

Components are self-contained units that can be:

- Independently developed and tested
- Easily enabled or disabled
- Combined without conflicts
- Versioned and distributed separately

**Example Applications:**

- Rice themes (12+ self-contained themes)
- Quickshell modules (bar, launcher, dashboard, session, control center)
- Utility scripts (100+ independent tools)

### 3. Single Source of Truth

Configuration data flows from centralized sources:

- Color palettes: `~/.cache/wal/colors` (pywal) → `~/.cache/dots/smart-colors/`
- Rice configs: `~/.local/share/dots/rices/<rice-name>/config.sh`
- Environment: Detected dynamically, not hardcoded
- State: Centralized in known locations (`~/.cache/dots/`, `~/.config/`)

### 4. Graceful Degradation

Systems must function even when:

- Optional dependencies are missing
- Network connectivity is unavailable
- Hardware features are absent
- Configuration files are incomplete

**Implementation Strategy:**

- Check for command availability before use
- Provide sensible defaults
- Implement fallback mechanisms
- Log degraded functionality warnings

### 5. Security by Default

Security is not optional or afterthought:

- Secrets never committed to version control
- File permissions enforced automatically
- User input validated before processing
- External commands executed safely
- Temporary files cleaned up reliably

## System Architecture Overview

### Major Subsystems

1. **Theme System (Rice)** - Complete desktop theme management
2. **Smart Colors System** - Intelligent color adaptation
3. **Quickshell Shell** - Unified status bar, launcher, dashboard, notifications, and control center
4. **Script Management (dots)** - Unified utility interface

For detailed architecture of each subsystem, see [System Architecture](System-Architecture.md).

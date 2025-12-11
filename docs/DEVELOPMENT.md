# Development Guide

## Local Development with Just

This project uses `just` + `mise` for local builds and quality checks.

### Prerequisites

1. Install [mise](https://mise.jdx.dev/) and run:

```bash
mise install
```

2. Install Xcode from the App Store

### Building

```bash
# Build debug (simulator)
just build

# Build release
just build-release

# Build for testing
just build-for-testing

# Clean build artifacts
just build-clean
```

### Testing

```bash
# Run unit tests
just test

# Run UI tests
just test-ui
```

### Quality Checks

```bash
# Run all quality checks
just verify

# Setup devtools (first time only)
just setup-devtools

# Run specific checks
just lint-all         # All linters
just lint-commits     # Commit message check
just lint-license     # License/REUSE check
just lint-yaml        # YAML files
just lint-markdown    # Markdown files
just lint-shell       # Shell scripts
just lint-actions     # GitHub Actions

# Auto-fix issues
just lint-fix
```

### All Available Recipes

```bash
just --list
```

## Xcode Development

### Opening the Project

```bash
open Wallet.xcodeproj
```

### Schemes

- **Wallet Demo** - Main development scheme

### Running on Simulator

1. Open Xcode
2. Select "Wallet Demo" scheme
3. Choose a simulator (e.g., iPhone 15)
4. Press Cmd+R to build and run

### Running on Device

1. Connect your iOS device
2. Select your device in Xcode
3. Ensure signing is configured in project settings
4. Press Cmd+R to build and run

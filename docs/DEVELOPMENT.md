# Development Guide

## Local Development with Just

This project uses `just` + `mise` for local builds and quality checks.

### Prerequisites - Linux

1. Install [mise](https://mise.jdx.dev/):

   ```bash
   curl https://mise.run | sh
   ```

2. Activate mise in your shell:

   ```bash
   # For bash - add to ~/.bashrc
   eval "$(mise activate bash)"

   # For zsh - add to ~/.zshrc
   eval "$(mise activate zsh)"

   # For fish - add to ~/.config/fish/config.fish
   mise activate fish | source
   ```

   Then restart your terminal.

3. Install pipx:

   ```bash
   # Debian/Ubuntu
   sudo apt install pipx
   ```

4. Install project tools:

   ```bash
   mise install
   ```

5. Show available tasks:

   ```bash
   just
   ```

### Prerequisites - macOS

1. Install Xcode from the App Store

2. Install [mise](https://mise.jdx.dev/):

   ```bash
   brew install mise
   ```

3. Activate mise in your shell:

   ```bash
   # For zsh - add to ~/.zshrc
   eval "$(mise activate zsh)"

   # For bash - add to ~/.bashrc
   eval "$(mise activate bash)"

   # For fish - add to ~/.config/fish/config.fish
   mise activate fish | source
   ```

   Then restart your terminal.

4. Install newer bash than macOS default:

   ```bash
   brew install bash
   ```

5. Install pipx:

   ```bash
   brew install pipx
   ```

6. Install project tools:

   ```bash
   mise install
   ```

7. Show available tasks:

   ```bash
   just
   ```

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

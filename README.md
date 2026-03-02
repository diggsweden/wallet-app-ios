# Wallet iOS

[![License: EUPL 1.2](https://img.shields.io/badge/License-European%20Union%20Public%20Licence%201.2-library?style=for-the-badge&&color=lightblue)](LICENSE)
[![REUSE](https://img.shields.io/badge/dynamic/json?url=https%3A%2F%2Fapi.reuse.software%2Fstatus%2Fgithub.com%2Fdiggsweden%2Fwallet-app-ios&query=status&style=for-the-badge&label=REUSE&color=lightblue)](https://api.reuse.software/info/github.com/diggsweden/wallet-app-ios)

[![Tag](https://img.shields.io/github/v/tag/diggsweden/wallet-app-ios?style=for-the-badge&color=green)](https://github.com/diggsweden/wallet-app-ios/tags)

[![OpenSSF Scorecard](https://api.scorecard.dev/projects/github.com/diggsweden/wallet-app-ios/badge?style=for-the-badge)](https://scorecard.dev/viewer/?uri=github.com/diggsweden/wallet-app-ios)

## Development Setup

### Prerequisites

- Xcode 26 or later
- [mise](https://mise.jdx.dev) — tool version manager (installs `just`, `xcodegen`, and linters)
- [just](https://github.com/casey/just) — command runner used for all development tasks
- An API key for the sandbox environment (contact the team to obtain one)

### 1. Install tools and git hooks

Install [mise](https://mise.jdx.dev/getting-started.html), then run:

```sh
just install       # installs all tools via mise (xcodegen, just, linters, …)
just install-hooks # installs pre-push, post-merge, post-checkout git hooks
```

Run `just` in the repo root at any time to see all available commands.

### 2. Generate the Xcode project

`Wallet.xcodeproj` is not checked in. It must be generated from the `project.yml` spec before opening the project in Xcode:

```sh
xcodegen generate
```

Re-run this command whenever `project.yml` changes (e.g. after pulling new commits that modify it).

### 3. Create your local config files

The xcconfig files that contain API keys are gitignored and must be created locally from the provided examples.

```sh
cp Configurations/Config-Debug.xcconfig.example Configurations/Config-Debug.xcconfig
# Optional — only needed if running backend services locally:
cp Configurations/Config-Localhost.xcconfig.example Configurations/Config-Localhost.xcconfig
```

Open each file and set `API_KEY` to your API key.

> **Never commit these files.** They are listed in `.gitignore` for this reason.
>
> Both files are referenced in the generated `Wallet.xcodeproj` and will appear in the project navigator automatically once they exist on disk. If they are missing, Xcode shows them with a red missing-file indicator — this is expected until you run the `cp` step above.

### 4. Select a scheme

| Scheme | Config file | Backend |
|---|---|---|
| `Wallet Demo` | `Config-Debug.xcconfig` | `https://wallet.sandbox.digg.se` |
| `Wallet Demo Localhost` | `Config-Localhost.xcconfig` | `https://localhost` |

Select the scheme from the Xcode toolbar and run on a simulator or device.

---

## Available Commands

Run `just` at any time to see all commands. Here's the full reference:

### Setup

| Command | Description |
|---|---|
| `just install` | Install devtools and tools (start here) |
| `just install-hooks` | Install git hooks (pre-push, post-merge, post-checkout) |
| `just setup-devtools` | Clone or update devbase-check tooling |
| `just tools-install` | Install tools via mise |
| `just check-tools` | Verify all required tools are installed |

### Build

| Command | Description |
|---|---|
| `just build` | Build debug for simulator (iPhone 15) |
| `just build-release` | Build release |
| `just build-for-testing` | Build for testing |
| `just build-clean` | Clean build artifacts |

### Test

| Command | Description |
|---|---|
| `just test` | Run unit tests on simulator |
| `just test-ui` | Run UI tests on simulator |

### Quality

| Command | Description |
|---|---|
| `just verify` | Run all checks (lint + tool verification) |
| `just lint-all` | Run all linters with summary |
| `just lint-fix` | Auto-fix all fixable issues |
| `just lint-commits` | Validate commit messages |
| `just lint-secrets` | Scan for secrets |
| `just lint-yaml` | Lint YAML files |
| `just lint-yaml-fix` | Fix YAML formatting |
| `just lint-markdown` | Lint Markdown files |
| `just lint-markdown-fix` | Fix Markdown formatting |
| `just lint-shell` | Lint shell scripts |
| `just lint-shell-fmt` | Check shell formatting |
| `just lint-shell-fmt-fix` | Fix shell formatting |
| `just lint-actions` | Lint GitHub Actions workflows |
| `just lint-license` | Check license compliance (REUSE) |

---

## License

Source code is EUPL-1.2. Most other assets are CC0-1.0

Copies from Apple App Store are licensed under their store EULA plus our Terms of Use; that doesn’t change the EUPL license for the source.

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

### 1. Install tools

Install [mise](https://mise.jdx.dev/getting-started.html), then run:

```sh
just install   # installs all tools via mise + git hooks
```

Run `just` in the repo root at any time to see all available commands.

### 2. Generate the Xcode project and open the workspace

`Wallet.xcodeproj` is not checked in — it is generated from `project.yml`. Generate it and open the workspace in one step:

```sh
just generate   # runs xcodegen
just open       # opens Wallet.xcworkspace in Xcode
```

> **Always open `Wallet.xcworkspace`, never `Wallet.xcodeproj` directly.**
> Opening the project file instead of the workspace causes Xcode to manage
> `Package.resolved` inside .xcodeproj instead of on workspace level

Re-run `just generate` whenever `project.yml` changes (e.g. after pulling commits that modify it). The post-merge and post-checkout git hooks do this automatically.

### 3. Create your local config files

The xcconfig files that contain API keys are gitignored and must be created locally from the provided examples. If you ran `just install` in step 1, this was already done for you. Otherwise, run:

```sh
just setup-configuration
```

This creates two files:

- `Configurations/Config-Debug.xcconfig` — used by the `Wallet Demo` scheme (sandbox backend)
- `Configurations/Config-Localhost.xcconfig` — used by the `Wallet Demo Localhost` scheme (local backend)

Open each file and set `API_KEY` to your API key.

> **Never commit these files.** They are listed in `.gitignore`
>
> Both files are referenced in the generated `Wallet.xcodeproj` and will appear in the project navigator automatically once they exist on disk. If they are missing, Xcode shows them with a red missing-file indicator — this is expected until you create them.

### 4. Select a scheme

| Scheme                  | Config file                 | Backend                          |
| ----------------------- | --------------------------- | -------------------------------- |
| `Wallet Demo`           | `Config-Debug.xcconfig`     | `https://wallet.sandbox.digg.se` |
| `Wallet Demo Localhost` | `Config-Localhost.xcconfig` | `https://localhost`              |

Select the scheme from the Xcode toolbar and run on a simulator or device.

---

## Linting

The project uses two complementary Swift linting tools, both installed via mise:

| Tool | Purpose | Config |
| ---- | ------- | ------ |
| [SwiftLint](https://github.com/realm/SwiftLint) | Enforces Swift style and best-practice rules | `.swiftlint.yml` |
| [swift-format](https://github.com/swiftlang/swift-format) | Enforces consistent code formatting | `.swift-format` |

Both run automatically as a pre-build script in Xcode and as a pre-push git hook.

### Running linters manually

```sh
just lint-swift          # SwiftLint
just lint-swift-format   # swift-format
```

### Auto-fixing

```sh
just lint-swift-format-fix   # reformat all Swift files with swift-format
just lint-swift-fix          # apply SwiftLint auto-corrections
just lint-fix                # run all auto-fixes (includes swift-format)
```

---

## Available Commands

Run `just` at any time to see all commands.

## License

Source code is EUPL-1.2. Most other assets are CC0-1.0

Copies from Apple App Store are licensed under their store EULA plus our Terms of Use; that doesn’t change the EUPL license for the source.

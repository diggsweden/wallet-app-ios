# Wallet iOS

[![License: EUPL 1.2](https://img.shields.io/badge/License-European%20Union%20Public%20Licence%201.2-library?style=for-the-badge&&color=lightblue)](LICENSE)
[![REUSE](https://img.shields.io/badge/dynamic/json?url=https%3A%2F%2Fapi.reuse.software%2Fstatus%2Fgithub.com%2Fdiggsweden%2Fwallet-app-ios&query=status&style=for-the-badge&label=REUSE&color=lightblue)](https://api.reuse.software/info/github.com/diggsweden/wallet-app-ios)

[![Tag](https://img.shields.io/github/v/tag/diggsweden/wallet-app-ios?style=for-the-badge&color=green)](https://github.com/diggsweden/wallet-app-ios/tags)

[![OpenSSF Scorecard](https://api.scorecard.dev/projects/github.com/diggsweden/wallet-app-ios/badge?style=for-the-badge)](https://scorecard.dev/viewer/?uri=github.com/diggsweden/wallet-app-ios)

## Development Setup

### Prerequisites

- Xcode 26 or later
- An API key for the sandbox environment (contact the team to obtain one)

### 1. Create your local config files

The xcconfig files that contain API keys are gitignored and must be created locally from the provided examples.

```sh
cp Config-Debug.xcconfig.example Config-Debug.xcconfig
# Optional — only needed if running backend services locally:
cp Config-Localhost.xcconfig.example Config-Localhost.xcconfig
```

Open each file and set `API_KEY` to your API key.

> **Never commit these files.** They are listed in `.gitignore` for this reason.
>
> Both files are already referenced in `Wallet.xcodeproj` and will appear in the project navigator automatically once they exist on disk. Before the `cp` step, Xcode shows them with a red missing-file indicator — this is expected.

### 2. Select a scheme

| Scheme | Config file | Backend |
|---|---|---|
| `Wallet Demo` | `Config-Debug.xcconfig` | `https://wallet.sandbox.digg.se` |
| `Wallet Demo Localhost` | `Config-Localhost.xcconfig` | `https://localhost` |

Select the scheme from the Xcode toolbar and run on a simulator or device.

---

## License

Source code is EUPL-1.2. Most other assets are CC0-1.0

Copies from Apple App Store are licensed under their store EULA plus our Terms of Use; that doesn’t change the EUPL license for the source.

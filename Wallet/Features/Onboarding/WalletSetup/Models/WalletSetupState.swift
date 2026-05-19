// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

enum WalletSetupState {
  case idle
  case working(WalletSetupStep)
  case failed(at: WalletSetupStep, error: Error)
  case complete
}

extension WalletSetupState: Equatable {
  static func == (lhs: Self, rhs: Self) -> Bool {
    switch (lhs, rhs) {
      case (.idle, .idle), (.complete, .complete): true
      case (.working(let a), .working(let b)): a == b
      case (.failed(let a, _), .failed(let b, _)): a == b
      default: false
    }
  }
}

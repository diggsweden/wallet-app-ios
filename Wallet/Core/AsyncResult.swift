// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

enum AsyncResult<Value> {
  case idle
  case loading
  case success(Value)
  case failure(Error)
}

extension AsyncResult: Equatable where Value: Equatable {
  static func == (l: Self, r: Self) -> Bool {
    switch (l, r) {
      case (.idle, .idle), (.loading, .loading): return true
      case let (.success(a), .success(b)): return a == b
      case (.failure, .failure): return true
      default: return false
    }
  }
}

extension AsyncResult {
  var isLoading: Bool {
    if case .loading = self {
      true
    } else {
      false
    }
  }

  var value: Value? {
    if case let .success(value) = self {
      value
    } else {
      nil
    }
  }

  var error: Error? {
    if case let .failure(error) = self {
      error
    } else {
      nil
    }
  }
}

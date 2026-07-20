// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

enum IssuancePhaseAnimationKey: Equatable {
  case fetchingIssuer
  case readyToAuthorize
  case authorizing
  case readyToSign
  case readyToFetch
  case fetchingCredential
  case done
  case error
}

extension IssuancePhase {
  var animationKey: IssuancePhaseAnimationKey {
    switch self {
      case .fetchingIssuer: .fetchingIssuer
      case .readyToAuthorize: .readyToAuthorize
      case .authorizing: .authorizing
      case .readyToSign: .readyToSign
      case .readyToFetch: .readyToFetch
      case .fetchingCredential: .fetchingCredential
      case .done: .done
      case .error: .error
    }
  }

  var isError: Bool {
    animationKey == .error
  }
}

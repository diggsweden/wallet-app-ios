// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

extension BootstrapViewModel {
  enum State {
    case loading
    case accountReset(AppDependencies)
    case ready(AppDependencies)
    case error(CaughtError)
    case backendCheckFailed(CaughtError)
    case databaseInitializationFailed(CaughtError)

    // swiftlint:disable:next nesting
    enum AnimationKey: Equatable {
      case loading
      case accountReset
      case ready
      case error
      case backendCheckFailed
      case databaseInitializationFailed
    }

    var animationKey: AnimationKey {
      switch self {
        case .loading:
          .loading

        case .accountReset:
          .accountReset

        case .ready:
          .ready

        case .error:
          .error

        case .backendCheckFailed:
          .backendCheckFailed

        case .databaseInitializationFailed:
          .databaseInitializationFailed
      }
    }
  }
}

// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import SwiftUI

@MainActor
@Observable
final class BootstrapViewModel {
  private(set) var state: State = .loading
  private var isBootstrapping = false
  private var bootstrapper: Bootstrapper?
  private let makeServices: @Sendable () async throws -> WalletServices

  init(makeServices: @escaping @Sendable () async throws -> WalletServices = WalletServices.make) {
    self.makeServices = makeServices
  }

  func bootstrap() async {
    guard !isBootstrapping else {
      return
    }

    isBootstrapping = true
    state = .loading

    defer {
      isBootstrapping = false
    }

    let bootstrapper: Bootstrapper
    do {
      bootstrapper = try await getOrCreateBootstrapper()
    } catch {
      state = .databaseInitializationFailed(CaughtError(error))
      return
    }

    do {
      state = try await bootstrapper.start()
    } catch {
      state = .error(CaughtError(error))
    }
  }

  func signOut() async {
    guard let bootstrapper else {
      return
    }

    do {
      state = try await bootstrapper.signOut(isReset: false)
    } catch {
      state = .error(CaughtError(error))
    }
  }

  func acknowledgeAccountReset(dependencies: AppDependencies) {
    state = .ready(dependencies)
  }

  private func getOrCreateBootstrapper() async throws -> Bootstrapper {
    if let bootstrapper {
      return bootstrapper
    }

    let bootstrapper = Bootstrapper(services: try await makeServices())
    self.bootstrapper = bootstrapper
    return bootstrapper
  }
}

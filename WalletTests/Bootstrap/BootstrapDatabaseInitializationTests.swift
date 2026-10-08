// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import Foundation
import Testing

@testable import WalletDemo

extension BootstrapViewModelTests {
  @Test("Database initialization failures can be retried")
  func databaseInitializationFailure() async throws {
    let attempts = AttemptCounter()
    let viewModel = BootstrapViewModel(makeServices: {
      await attempts.increment()
      throw CocoaError(.fileReadCorruptFile)
    })

    #expect(await attempts.value == 0)
    await viewModel.bootstrap()
    guard case let .databaseInitializationFailed(caught) = viewModel.state else {
      Issue.record("Expected a database initialization failure")
      return
    }
    #expect(caught.message != nil)
    #expect(await attempts.value == 1)

    for expectedAttempts in 2 ... 3 {
      await viewModel.bootstrap()
      guard case .databaseInitializationFailed = viewModel.state else {
        Issue.record("Expected the same database initialization error after retrying")
        return
      }
      #expect(await attempts.value == expectedAttempts)
    }
  }

  @Test("A successful database initialization retry resumes bootstrap and caches the services")
  func databaseInitializationRetrySucceeds() async throws {
    let store = try makeStore()
    let gateway = DatabaseUpdateGateway()
    let attempts = AttemptCounter()
    let viewModel = BootstrapViewModel(makeServices: {
      if await attempts.increment() == 1 { throw CocoaError(.fileReadCorruptFile) }
      return WalletServices(userStore: store, gatewayApiClient: gateway)
    })

    await viewModel.bootstrap()
    #expect(viewModel.state.animationKey == .databaseInitializationFailed)
    await viewModel.bootstrap()
    #expect(try #require(loadedUser(viewModel)).hasCompletedOnboarding)
    #expect(await attempts.value == 2)
    #expect(await gateway.calls == 1)

    await viewModel.bootstrap()
    #expect(try #require(loadedUser(viewModel)).hasCompletedOnboarding)
    #expect(await attempts.value == 2)
  }
}

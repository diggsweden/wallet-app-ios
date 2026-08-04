// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import Testing

@testable import WalletGateway

@Suite("GatewayError descriptions")
struct GatewayErrorTests {
  @Test("problem prefers the title")
  func problemPrefersTitle() {
    let details = ProblemDetails(
      status: 500,
      type: nil,
      title: "Boom",
      detail: "detaljer",
      instance: nil,
      transactionId: nil,
      invalidParameters: nil,
    )

    #expect(GatewayError.problem(details).errorDescription == "Boom")
  }

  @Test("problem falls back to the status when title and detail are absent")
  func problemFallsBackToStatus() {
    let details = ProblemDetails(
      status: 502,
      type: nil,
      title: nil,
      detail: nil,
      instance: nil,
      transactionId: nil,
      invalidParameters: nil,
    )

    #expect(GatewayError.problem(details).errorDescription == "Servern returnerade ett fel (502).")
  }

  @Test("unauthorized has a user-facing message")
  func unauthorized() {
    #expect(GatewayError.unauthorized.errorDescription == "Sessionen är ogiltig eller har gått ut.")
  }
}

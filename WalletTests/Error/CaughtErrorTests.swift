// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import Foundation
import Testing
import WalletGateway

@testable import WalletDemo

@Suite("CaughtError extraction")
struct CaughtErrorTests {
  private let date = Date(timeIntervalSince1970: 1_700_000_000)

  @Test("backend problem keeps status, message, endpoint and its transaction id as the trace")
  func gatewayProblem() {
    let details = ProblemDetails(
      status: 500,
      title: "Internal Server Error",
      instance: "/v0/accounts",
      transactionId: "txn-123"
    )
    let caught = CaughtError(GatewayError.problem(details), at: date)

    #expect(caught.code == "500")
    #expect(caught.message == "Internal Server Error")
    #expect(caught.endpoint == "/v0/accounts")
    #expect(caught.traceId == "txn-123")
    #expect(caught.occurredAt == date)
  }

  @Test("app-thrown error uses the catch-site file and line as the trace")
  func appThrownTrace() {
    let caught = CaughtError(
      GatewayError.invalidResponse,
      at: date,
      file: "WalletDemo/WalletSetupViewModel.swift",
      line: 56
    )

    #expect(caught.code == nil)
    #expect(caught.traceId == "app-trace - WalletDemo/WalletSetupViewModel.swift:56")
  }

  @Test("gateway unauthorized has no code and falls back to the catch-site trace")
  func gatewayUnauthorized() {
    let caught = CaughtError(
      GatewayError.unauthorized,
      at: date,
      file: "WalletDemo/Flow.swift",
      line: 10
    )

    #expect(caught.code == nil)
    #expect(caught.message == "Sessionen är ogiltig eller har gått ut.")
    #expect(caught.traceId == "app-trace - WalletDemo/Flow.swift:10")
  }

  @Test("http error keeps the status and url and surfaces the server's OAuth message")
  func httpError() {
    let url = URL(string: "https://issuer.example.com/token")
    let body = Data(#"{"error":"invalid_grant","error_description":"expired"}"#.utf8)
    let caught = CaughtError(HTTPError.http(status: 400, url: url, body: body), at: date)

    #expect(caught.code == "400")
    #expect(caught.endpoint == "issuer.example.com/token")
    #expect(caught.message == "invalid_grant: expired")
  }

  @Test("presentation resolution failure surfaces the detail message")
  func presentationResolution() {
    let caught = CaughtError(PresentationError.resolutionFailed("boom"), at: date)

    #expect(caught.message == "boom")
  }

  @Test("unknown error falls back to its message")
  func fallback() {
    struct Boom: LocalizedError {
      var errorDescription: String? { "kaboom" }
    }
    let caught = CaughtError(Boom(), at: date)

    #expect(caught.code == nil)
    #expect(caught.message == "kaboom")
  }

  @Test("ErrorInfo combines the caught primitives with the system snapshot")
  func combinesWithSystemSnapshot() {
    let system = SystemInfo(
      appVersion: "1.0 (1)",
      iosVersion: "26.0.0",
      deviceModel: "iPhone15,2",
      network: "Wi-Fi"
    )
    let caught = CaughtError(GatewayError.unauthorized, at: date)
    let info = ErrorInfo(from: caught, system: system)

    #expect(info.message == "Sessionen är ogiltig eller har gått ut.")
    #expect(info.appVersion == "1.0 (1)")
    #expect(info.deviceModel == "iPhone15,2")
    #expect(info.network == "Wi-Fi")
    #expect(info.timestamp == ErrorInfo.timeFormatter.string(from: date))
  }
}

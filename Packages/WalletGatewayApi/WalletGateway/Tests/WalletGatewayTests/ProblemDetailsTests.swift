// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import Testing

@testable import WalletGateway

@Suite("ProblemDetails mapping")
struct ProblemDetailsTests {
  @Test("maps every field from a problem response")
  func mapsAllFields() {
    let response = Components.Responses.Default(
      body: .applicationProblemJson(
        Components.Schemas.ProblemResponse(
          _type: "about:blank",
          status: 500,
          title: "Internal Server Error",
          detail: "Kunde inte hämta innehåll från servern",
          instance: "/v0/accounts",
          transactionId: "abcdefgh-digg-38sdgj5",
          invalidParameters: [
            .init(reason: "required", value: nil, property: "deviceKey")
          ]
        )
      )
    )

    let details = ProblemDetails(status: 500, response: response)

    #expect(details.status == 500)
    #expect(details.type == "about:blank")
    #expect(details.title == "Internal Server Error")
    #expect(details.detail == "Kunde inte hämta innehåll från servern")
    #expect(details.instance == "/v0/accounts")
    #expect(details.transactionId == "abcdefgh-digg-38sdgj5")
    #expect(details.invalidParameters?.count == 1)
    #expect(details.invalidParameters?.first?.property == "deviceKey")
    #expect(details.invalidParameters?.first?.reason == "required")
  }

  @Test("uses the output status even when the body omits optionals")
  func mapsMinimalBody() {
    let response = Components.Responses.Default(
      body: .applicationProblemJson(
        Components.Schemas.ProblemResponse(status: 503, title: "Service Unavailable")
      )
    )

    let details = ProblemDetails(status: 503, response: response)

    #expect(details.status == 503)
    #expect(details.title == "Service Unavailable")
    #expect(details.detail == nil)
    #expect(details.transactionId == nil)
    #expect(details.invalidParameters == nil)
  }
}

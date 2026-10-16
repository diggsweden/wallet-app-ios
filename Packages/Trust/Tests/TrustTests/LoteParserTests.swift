// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import Foundation
import Testing

@testable import Trust

struct LoteParserTests {
  private let services = [
    Fixtures.Service(
      type: ServiceType.wrpacIssuance.rawValue,
      certificates: ["cert-a", "cert-b"],
    ),
    Fixtures.Service(type: ServiceType.wrprcIssuance.rawValue, certificates: ["cert-c"]),
  ]

  @Test func `a json list is decoded with its services and certificates`() throws {
    let trust = try LoteParser.parse(
      LoteResponse(data: Fixtures.loteJson(services), type: .json)
    )

    expectServices(in: trust)
  }

  @Test(arguments: [LoteContentType.jwt, .jose])
  func `a signed list is decoded from its payload`(type: LoteContentType) throws {
    let trust = try LoteParser.parse(
      LoteResponse(data: Fixtures.loteJwt(services), type: type)
    )

    expectServices(in: trust)
  }

  @Test func `the list dates are decoded as iso8601`() throws {
    let trust = try LoteParser.parse(
      LoteResponse(data: Fixtures.loteJson(services), type: .json)
    )

    let information = trust.loTE.listAndSchemeInformation
    #expect(information.listIssueDateTime == Date(timeIntervalSince1970: 1_767_225_600))
    #expect(information.nextUpdate == Date(timeIntervalSince1970: 1_782_864_000))
  }

  @Test func `a json list without the LoTE root fails to decode`() {
    let response = LoteResponse(data: Data(#"{"TrustedEntitiesList":[]}"#.utf8), type: .json)

    #expect(throws: DecodingError.self) {
      try LoteParser.parse(response)
    }
  }

  @Test func `a json body sent as a jwt fails to parse`() throws {
    let response = LoteResponse(data: try Fixtures.loteJson(services), type: .jwt)

    #expect(throws: (any Error).self) {
      try LoteParser.parse(response)
    }
  }

  private func expectServices(in trust: Trust) {
    let information = trust.loTE.trustedEntitiesList
      .flatMap(\.trustedEntityServices)
      .map(\.serviceInformation)

    #expect(information.map(\.serviceTypeIdentifier) == services.map(\.type))
    #expect(
      information.map { $0.serviceDigitalIdentity.x509Certificates.map(\.val) }
        == services.map(\.certificates)
    )
  }
}

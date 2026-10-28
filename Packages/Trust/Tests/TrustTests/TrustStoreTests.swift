// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import Foundation
import Testing
import WalletMacros

@testable import Trust

struct TrustStoreTests {
  private let first = #URL("https://first.example.com/lote")
  private let second = #URL("https://second.example.com/lote")
  private let wrpac = ServiceType.access.rawValue
  private let wrprc = ServiceType.registration.rawValue

  private func makeStore(
    providerUrls: [URL]?,
    responses: [URL: LoteResponse] = [:],
  ) -> TrustStore {
    TrustStore(
      walletGatewayApi: FakeGatewayApi(providerUrls: providerUrls),
      trustListFetcher: FakeTrustListFetcher(responses: responses),
    )
  }

  private func json(_ services: [Fixtures.Service]) throws -> LoteResponse {
    LoteResponse(data: try Fixtures.loteJson(services), type: .json)
  }

  @Test func `anchors are grouped by service type`() async throws {
    let store = makeStore(
      providerUrls: [first],
      responses: [
        first: try json([
          Fixtures.Service(type: wrpac, certificates: [Fixtures.rootCertificate]),
          Fixtures.Service(type: wrprc, certificates: [Fixtures.otherCertificate]),
        ])
      ],
    )

    let wrpacAnchors = try await store.getTrustAnchors(for: wrpac)
    let wrprcAnchors = try await store.getTrustAnchors(for: wrprc)

    #expect(wrpacAnchors.map(Fixtures.der) == [try Fixtures.der(of: Fixtures.rootCertificate)])
    #expect(wrprcAnchors.map(Fixtures.der) == [try Fixtures.der(of: Fixtures.otherCertificate)])
  }

  @Test func `anchors for the same service type are merged across providers`() async throws {
    let store = makeStore(
      providerUrls: [first, second],
      responses: [
        first: try json([Fixtures.Service(type: wrpac, certificates: [Fixtures.rootCertificate])]),
        second: try json([
          Fixtures.Service(type: wrpac, certificates: [Fixtures.otherCertificate])
        ]),
      ],
    )

    let anchors = try await store.getTrustAnchors(for: wrpac)

    #expect(
      Set(anchors.map(Fixtures.der))
        == [
          try Fixtures.der(of: Fixtures.rootCertificate),
          try Fixtures.der(of: Fixtures.otherCertificate),
        ]
    )
  }

  @Test func `a jwt list from a provider is used for anchors`() async throws {
    let services = [Fixtures.Service(type: wrpac, certificates: [Fixtures.rootCertificate])]
    let store = makeStore(
      providerUrls: [first],
      responses: [first: LoteResponse(data: try Fixtures.loteJwt(services), type: .jwt)],
    )

    let anchors = try await store.getTrustAnchors(for: wrpac)

    #expect(anchors.map(Fixtures.der) == [try Fixtures.der(of: Fixtures.rootCertificate)])
  }

  @Test func `a failing provider is skipped and the others are still used`() async throws {
    let store = makeStore(
      providerUrls: [first, second],
      responses: [
        second: try json([Fixtures.Service(type: wrpac, certificates: [Fixtures.rootCertificate])])
      ],
    )

    let anchors = try await store.getTrustAnchors(for: wrpac)

    #expect(anchors.map(Fixtures.der) == [try Fixtures.der(of: Fixtures.rootCertificate)])
  }

  @Test func `a provider returning an unparsable list is skipped`() async throws {
    let store = makeStore(
      providerUrls: [first, second],
      responses: [
        first: LoteResponse(data: Data("not a list".utf8), type: .json),
        second: try json([Fixtures.Service(type: wrpac, certificates: [Fixtures.rootCertificate])]),
      ],
    )

    let anchors = try await store.getTrustAnchors(for: wrpac)

    #expect(anchors.map(Fixtures.der) == [try Fixtures.der(of: Fixtures.rootCertificate)])
  }

  @Test func `a certificate that cannot be decoded is dropped`() async throws {
    let store = makeStore(
      providerUrls: [first],
      responses: [
        first: try json([
          Fixtures.Service(
            type: wrpac,
            certificates: ["bm90IGEgY2VydGlmaWNhdGU", Fixtures.rootCertificate],
          )
        ])
      ],
    )

    let anchors = try await store.getTrustAnchors(for: wrpac)

    #expect(anchors.map(Fixtures.der) == [try Fixtures.der(of: Fixtures.rootCertificate)])
  }

  @Test func `an unknown service type throws`() async throws {
    let store = makeStore(
      providerUrls: [first],
      responses: [
        first: try json([Fixtures.Service(type: wrpac, certificates: [Fixtures.rootCertificate])])
      ],
    )

    await #expect(throws: TrustStoreError.self) {
      try await store.getTrustAnchors(for: ServiceType.registration.rawValue)
    }
  }

  @Test func `no providers means there are no trust anchors`() async {
    let store = makeStore(providerUrls: [])

    await #expect(throws: TrustStoreError.self) {
      try await store.getTrustAnchors(for: wrpac)
    }
  }

  @Test func `a gateway failure is surfaced to the caller`() async {
    let store = makeStore(providerUrls: nil)

    await #expect(throws: FakeGatewayApi.Failure.self) {
      try await store.getTrustAnchors(for: wrpac)
    }
  }

  @Test func `concurrent lookups share a single fetch`() async throws {
    let gateway = FakeGatewayApi(providerUrls: [first])
    let store = TrustStore(
      walletGatewayApi: gateway,
      trustListFetcher: FakeTrustListFetcher(responses: [
        first: try json([Fixtures.Service(type: wrpac, certificates: [Fixtures.rootCertificate])])
      ]),
    )

    async let firstLookup = store.getTrustAnchors(for: wrpac)
    async let secondLookup = store.getTrustAnchors(for: wrpac)
    async let thirdLookup = store.getTrustAnchors(for: wrpac)
    _ = try await (firstLookup, secondLookup, thirdLookup)

    #expect(await gateway.providerFetchCount == 1)
  }

  @Test func `a failed load is retried on the next lookup`() async throws {
    let store = TrustStore(
      walletGatewayApi: FakeGatewayApi(providerUrls: [first], failingCalls: 1),
      trustListFetcher: FakeTrustListFetcher(responses: [
        first: try json([Fixtures.Service(type: wrpac, certificates: [Fixtures.rootCertificate])])
      ]),
    )

    _ = try? await store.getTrustAnchors(for: wrpac)
    let anchors = try await store.getTrustAnchors(for: wrpac)

    #expect(anchors.map(Fixtures.der) == [try Fixtures.der(of: Fixtures.rootCertificate)])
  }

  @Test func `an empty load is refetched on the next lookup`() async throws {
    let store = TrustStore(
      walletGatewayApi: FakeGatewayApi(providerUrls: [first]),
      trustListFetcher: FakeTrustListFetcher(
        responses: [
          first: try json([
            Fixtures.Service(type: wrpac, certificates: [Fixtures.rootCertificate])
          ])
        ],
        failingCalls: 1,
      ),
    )

    _ = try? await store.getTrustAnchors(for: wrpac)
    let anchors = try await store.getTrustAnchors(for: wrpac)

    #expect(anchors.map(Fixtures.der) == [try Fixtures.der(of: Fixtures.rootCertificate)])
  }
}

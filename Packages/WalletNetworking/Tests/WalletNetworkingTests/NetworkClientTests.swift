// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import Foundation
import Testing
import WalletMacros
import WalletNetworkingTestSupport

@testable import WalletNetworking

/// The decoding conveniences every `NetworkClient` gets, tested without a transport.
struct NetworkClientTests {
  private struct Payload: Decodable, Equatable {
    let cNonce: String
  }

  private let endpoint = #URL("https://issuer.example.com/nonce")

  @Test func `fetch decodes snake_case JSON into camelCase properties`() async throws {
    let client = FakeNetworkClient(body: #"{"c_nonce":"abc"}"#)

    let payload: Payload = try await client.fetch(endpoint)

    #expect(payload == Payload(cNonce: "abc"))
  }

  @Test func `a body that does not decode is a decoding error with the url`() async throws {
    let client = FakeNetworkClient(body: "not json")

    let error = await #expect(throws: HTTPError.self) {
      let _: Payload = try await client.fetch(endpoint)
    }

    guard case .decoding(_, let url)? = error else {
      Issue.record("expected a decoding error, got \(String(describing: error))")
      return
    }
    #expect(url == endpoint)
  }

  @Test func `fetchJwt returns the body as text`() async throws {
    let client = FakeNetworkClient(body: "header.claims.signature")

    let jwt = try await client.fetchJwt(endpoint)

    #expect(jwt == "header.claims.signature")
  }

  @Test func `a fetchJwt body that is not UTF-8 is a decoding error`() async throws {
    let client = FakeNetworkClient { _ in Data([0xFF, 0xFE]) }

    let error = await #expect(throws: HTTPError.self) {
      try await client.fetchJwt(endpoint)
    }

    guard case .decoding? = error else {
      Issue.record("expected a decoding error, got \(String(describing: error))")
      return
    }
  }
}

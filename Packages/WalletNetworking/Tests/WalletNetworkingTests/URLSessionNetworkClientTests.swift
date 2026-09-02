// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import Foundation
import Testing
import WalletMacros
import WalletNetworkingTestSupport

@testable import WalletNetworking

struct URLSessionNetworkClientTests {
  private let endpoint = #URL("https://issuer.example.com/credential")

  private let nonceChallenge = FakeHTTPTransport.Scripted.response(
    status: 401,
    headers: [
      "WWW-Authenticate": #"DPoP error="use_dpop_nonce""#,
      "DPoP-Nonce": "server-nonce",
    ],
  )

  private func dpopRequest(method: HTTPMethod = .get) -> NetworkRequest {
    NetworkRequest(
      url: endpoint,
      method: method,
      authorization: .dpop(accessToken: "token", proofBuilder: FakeDpopProofProvider()),
    )
  }

  @Test func `a 2xx response body is returned as is`() async throws {
    let transport = FakeHTTPTransport([.response(status: 200, body: Data("ok".utf8))])
    let client = URLSessionNetworkClient(transport: transport)

    let data = try await client.send(NetworkRequest(url: endpoint))

    #expect(String(bytes: data, encoding: .utf8) == "ok")
  }

  @Test func `a non-2xx status is an http error carrying the response and body`() async throws {
    let transport = FakeHTTPTransport([.response(status: 500, body: Data("boom".utf8))])
    let client = URLSessionNetworkClient(transport: transport)

    let error = await #expect(throws: HTTPError.self) {
      try await client.send(NetworkRequest(url: endpoint))
    }

    guard case .http(let response, let body)? = error else {
      Issue.record("expected an http error, got \(String(describing: error))")
      return
    }
    #expect(response.statusCode == 500)
    #expect(body == Data("boom".utf8))
  }

  @Test func `a transport failure is wrapped as a transport error with the url`() async throws {
    let transport = FakeHTTPTransport([.failure(.notConnectedToInternet)])
    let client = URLSessionNetworkClient(transport: transport)

    let error = await #expect(throws: HTTPError.self) {
      try await client.send(NetworkRequest(url: endpoint))
    }

    guard case .transport(_, let url)? = error else {
      Issue.record("expected a transport error, got \(String(describing: error))")
      return
    }
    #expect(url == endpoint)
  }

  @Test func `a response that is not HTTP is an invalid response with the url`() async throws {
    let transport = FakeHTTPTransport([.nonHttpResponse])
    let client = URLSessionNetworkClient(transport: transport)

    let error = await #expect(throws: HTTPError.self) {
      try await client.send(NetworkRequest(url: endpoint))
    }

    guard case .invalidResponse(let url)? = error else {
      Issue.record("expected an invalid response error, got \(String(describing: error))")
      return
    }
    #expect(url == endpoint)
  }

  @Test func `a DPoP request is retried once with the nonce from the challenge`() async throws {
    let transport = FakeHTTPTransport([
      nonceChallenge,
      .response(status: 200, body: Data("issued".utf8)),
    ])
    let client = URLSessionNetworkClient(transport: transport)

    let data = try await client.send(dpopRequest(method: .post))

    let requests = await transport.requests
    #expect(String(bytes: data, encoding: .utf8) == "issued")
    #expect(requests.count == 2)
    #expect(
      requests[0].value(forHTTPHeaderField: "DPoP")
        == "POST https://issuer.example.com/credential nonce=-"
    )
    #expect(
      requests[1].value(forHTTPHeaderField: "DPoP")
        == "POST https://issuer.example.com/credential nonce=server-nonce"
    )
  }

  @Test func `a second nonce challenge is not retried again`() async throws {
    let transport = FakeHTTPTransport([nonceChallenge, nonceChallenge])
    let client = URLSessionNetworkClient(transport: transport)

    await #expect(throws: HTTPError.self) {
      try await client.send(dpopRequest())
    }
    #expect(await transport.requests.count == 2)
  }

  @Test func `a bearer request is never retried on a nonce challenge`() async throws {
    let transport = FakeHTTPTransport([nonceChallenge])
    let client = URLSessionNetworkClient(transport: transport)

    await #expect(throws: HTTPError.self) {
      try await client.send(NetworkRequest(url: endpoint, authorization: .bearer("token")))
    }
    #expect(await transport.requests.count == 1)
  }
}

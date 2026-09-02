// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import CredentialInterfacesTestSupport
import CryptoKit
import Foundation
import Jose
import JoseTestSupport
import OpenId4VCInterface
import OpenId4VCInterfaceTestSupport
import Testing
import WalletMacros
import WalletNetworking
import WalletNetworkingTestSupport

@testable import Presentation

struct SubmitTests {
  private struct Submission {
    let outcome: PresentationOutcome
    let request: NetworkRequest
  }

  private func resolved(
    queryIds: [String] = ["pid"],
    state: String? = "state-1",
  ) throws -> ResolvedPresentation {
    try PresentationSession.match(
      Fixtures.request(queryIds.map { Fixtures.query(id: $0) }, state: state),
      credentials: [SampleCredential.saved()],
    )
  }

  /// Submits against a verifier that answers `verifierResponse`, returning the
  /// outcome together with the single request that reached the verifier.
  private func submit(
    _ resolved: ResolvedPresentation,
    selectedIds: [String] = ["pid"],
    signer: any ProofSigner = FakeProofSigner(),
    verifierResponse: String = "{}",
  ) async throws -> Submission {
    let network = FakeNetworkClient(body: verifierResponse)

    let outcome = try await PresentationSession(networkClient: network)
      .submit(resolved, selectedIds: selectedIds, signer: signer)

    return Submission(outcome: outcome, request: try #require(await network.lastRequest))
  }

  /// The form fields of a `direct_post` body, percent-decoded.
  private func formFields(of request: NetworkRequest) throws -> [String: String] {
    let body = try #require(request.bodyText)
    return try body.split(separator: "&")
      .reduce(into: [:]) { fields, pair in
        let parts = pair.split(separator: "=", maxSplits: 1).map(String.init)
        fields[try #require(parts.first)] = try #require(parts.last?.removingPercentEncoding)
      }
  }

  private func vpToken(of request: NetworkRequest) throws -> [String: [String]] {
    let fields = try formFields(of: request)
    let json = try #require(fields["vp_token"])
    return try JSONDecoder().decode([String: [String]].self, from: Data(json.utf8))
  }

  @Test func `posts a direct_post form with state, nonce and the vp_token`() async throws {
    let submission = try await submit(resolved())

    let fields = try formFields(of: submission.request)
    #expect(submission.outcome.redirectUrl == nil)
    #expect(submission.request.url == Fixtures.responseUrl)
    #expect(submission.request.method == .post)
    #expect(submission.request.contentType == "application/x-www-form-urlencoded")
    #expect(submission.request.authorization == nil)
    #expect(fields["state"] == "state-1")
    #expect(fields["nonce"] == "nonce-1")
    #expect(try vpToken(of: submission.request).keys.sorted() == ["pid"])
  }

  @Test func `each presented credential is the disclosed SD-JWT followed by a key-binding JWT`()
    async throws
  {
    let signer = FakeProofSigner()
    let resolved = try resolved()

    let submission = try await submit(resolved, signer: signer)

    let presentation = try #require(try vpToken(of: submission.request)["pid"]?.first)
    let disclosed = try #require(resolved.disclosedSdJwts["pid"])
    #expect(presentation.hasPrefix(disclosed))

    let keyBinding = try DecodedJwt(compact: String(presentation.dropFirst(disclosed.count)))
    #expect(keyBinding.headerString("typ") == "kb+jwt")
    #expect(keyBinding.claim("aud") == "verifier-1")
    #expect(keyBinding.claim("nonce") == "nonce-1")
    #expect(
      keyBinding.claim("sd_hash")
        == Data(SHA256.hash(data: Data(disclosed.utf8))).base64UrlEncodedString()
    )
    #expect(try keyBinding.verifies(with: signer.key.publicKey))
  }

  @Test func `only the selected credentials are presented`() async throws {
    let submission = try await submit(resolved(queryIds: ["must", "may"]), selectedIds: ["must"])

    #expect(try vpToken(of: submission.request).keys.sorted() == ["must"])
  }

  @Test func `the verifier's redirect_uri is returned`() async throws {
    let submission = try await submit(
      resolved(),
      verifierResponse: #"{"redirect_uri": "https://verifier.example/done?code=1"}"#,
    )

    #expect(submission.outcome.redirectUrl == #URL("https://verifier.example/done?code=1"))
  }

  @Test func `a request without state posts no state field`() async throws {
    let submission = try await submit(resolved(state: nil))

    #expect(try formFields(of: submission.request)["state"] == nil)
  }

  @Test func `selecting an id that was not resolved fails before anything is sent`() async throws {
    let network = FakeNetworkClient(body: "{}")
    let session = PresentationSession(networkClient: network)

    await #expect(throws: PresentationError.noMatchingCredential) {
      try await session.submit(
        try resolved(),
        selectedIds: ["pid", "ghost"],
        signer: FakeProofSigner(),
      )
    }
    #expect(await network.requests.isEmpty)
  }

  @Test func `a signer failure aborts before anything is sent`() async throws {
    let network = FakeNetworkClient(body: "{}")
    let session = PresentationSession(networkClient: network)

    await #expect(throws: FailingProofSigner.Failure.self) {
      try await session.submit(try resolved(), selectedIds: ["pid"], signer: FailingProofSigner())
    }
    #expect(await network.requests.isEmpty)
  }

  @Test func `a verifier error propagates`() async throws {
    let network = FakeNetworkClient(error: URLError(.badServerResponse))
    let session = PresentationSession(networkClient: network)

    await #expect(throws: URLError.self) {
      try await session.submit(try resolved(), selectedIds: ["pid"], signer: FakeProofSigner())
    }
  }
}

// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import CredentialInterfaces
import CryptoKit
import Foundation
import Jose
import OpenId4VCInterface
import SdJwtClaims
import WalletNetworking
import eudi_lib_sdjwt_swift

public struct PresentationSession: PresentationFlow {
  private let networkClient: any NetworkClient

  public init() {
    self.init(networkClient: URLSessionNetworkClient())
  }

  init(networkClient: any NetworkClient) {
    self.networkClient = networkClient
  }

  public func resolve(
    url: URL,
    credentials: [SavedCredential],
  ) async throws -> ResolvedPresentation {
    guard !credentials.isEmpty else {
      throw PresentationError.noCredential
    }

    return try Self.match(
      try await OpenId4VpRequestResolver().resolve(url: url),
      credentials: credentials,
    )
  }

  static func match(
    _ data: PresentationRequestData,
    credentials: [SavedCredential],
  ) throws -> ResolvedPresentation {
    let storedTypes: [String: SavedCredential] = credentials.reduce(into: [:]) { dict, credential in
      dict[credential.type] = credential
    }

    let matches: [MatchedCredential] = try data.credentialQueries.compactMap { query in
      guard let credential = query.vctValues.compactMap({ storedTypes[$0] }).first else {
        throw PresentationError.noMatchingCredential
      }
      return try Self.matchClaims(from: credential, to: query)
    }

    guard !matches.isEmpty else {
      throw PresentationError.noMatchingClaims
    }

    return ResolvedPresentation(
      candidates: matches.map(\.candidate),
      disclosedSdJwts: matches.reduce(into: [:]) { dict, match in
        dict[match.candidate.id] = match.serialisation
      },
      responseUrl: data.responseUrl,
      clientId: data.clientId,
      nonce: data.nonce,
      state: data.state,
    )
  }

  public func submit(
    _ resolved: ResolvedPresentation,
    selectedIds: [String],
    signer: any ProofSigner,
  ) async throws -> PresentationOutcome {
    var vpTokenEntries: [String: [String]] = [:]
    for id in selectedIds {
      guard let sdJwt = resolved.disclosedSdJwts[id] else {
        throw PresentationError.noMatchingCredential
      }
      let keyBindingJwt = try await Self.createKeyBinding(
        for: sdJwt,
        aud: resolved.clientId,
        nonce: resolved.nonce,
        signer: signer,
      )
      vpTokenEntries[id] = [sdJwt + keyBindingJwt]
    }

    let vpToken = VerifiablePresentationToken(
      state: resolved.state,
      nonce: resolved.nonce,
      vpToken: vpTokenEntries,
    )

    let response: RedirectUrl = try await networkClient.fetch(
      resolved.responseUrl,
      method: .post,
      contentType: "application/x-www-form-urlencoded",
      body: Data(try Self.createRequestBody(with: vpToken).utf8),
    )

    return PresentationOutcome(redirectUrl: response.redirectUri.flatMap { URL(string: $0) })
  }

  private struct MatchedCredential {
    let candidate: PresentationCandidate
    let serialisation: String
  }

  private static func matchClaims(
    from credential: SavedCredential,
    to query: CredentialQuery,
  ) throws -> MatchedCredential? {
    let sdJwt = try CompactParser().getSignedSdJwt(serialisedString: credential.compactSerialized)
    guard let disclosed = try sdJwt.present(query: query.claimPaths) else {
      return nil
    }

    return MatchedCredential(
      candidate: PresentationCandidate(
        id: query.id,
        required: query.required,
        claims: try disclosed.toClaimUiModels(displayNames: credential.claimDisplayNames),
      ),
      serialisation: disclosed.serialisation,
    )
  }

  static func createKeyBinding(
    for sdJwt: String,
    aud: String,
    nonce: String,
    signer: any ProofSigner,
  ) async throws -> String {
    guard let sdJwtData = sdJwt.data(using: .ascii) else {
      throw PresentationError.keyBindingEncodingFailed
    }

    let sdHash = Data(SHA256.hash(data: sdJwtData)).base64UrlEncodedString()
    let payload = KeyBindingPayload(aud: aud, nonce: nonce, sdHash: sdHash)

    return try await JwtUtil.signJwt(
      payload: payload,
      header: WalletJWSDefaultHeader(algorithm: .ES256, type: "kb+jwt"),
    ) { signingInput in
      try await signer.sign(signingInput)
    }
  }

  static func createRequestBody(with vpToken: VerifiablePresentationToken) throws -> String {
    let token = try JSONEncoder().encode(vpToken.vpToken)
    let allowed = CharacterSet.urlQueryAllowed.subtracting(.init(charactersIn: "+&="))

    var parts: [String] = []
    if let state = vpToken.state {
      parts.append("state=\(state)")
    }
    parts.append("nonce=\(vpToken.nonce)")
    let vpTokenString = String(bytes: token, encoding: .utf8) ?? ""
    let encodedVpToken =
      vpTokenString.addingPercentEncoding(withAllowedCharacters: allowed) ?? vpTokenString
    parts.append("vp_token=\(encodedVpToken)")

    return parts.joined(separator: "&")
  }
}

// SPDX-FileCopyrightText: 2026 diggsweden/wallet-app-ios
//
// SPDX-License-Identifier: EUPL-1.2

import CryptoKit
import Foundation
import JOSESwift
import OpenID4VCI
import OpenID4VP
import UIKit

@MainActor
@Observable
class PresentationViewModel {
  let data: ResolvedRequestData.VpTokenData
  let credential: Credential?
  var selectedDisclosures: [DisclosureSelection] = []
  let jwtUtil = JWTUtil()

  init(data: ResolvedRequestData.VpTokenData, credential: Credential?) {
    self.data = data
    self.credential = credential
  }

  func matchDisclosures() throws {
    guard case let .byDigitalCredentialsQuery(dcql) = data.presentationQuery else {
      throw AppError(reason: "We support only DCQL")
    }

    guard let credential else {
      throw AppError(reason: "No credential on device")
    }

    let claimPaths: [String] = dcql.credentials.reduce(into: []) { result, query in
      guard let claims = query.claims else {
        // Nil claims == verifier requests ALL disclosures
        return result.append(contentsOf: Array(credential.disclosures.keys))
      }

      let claimPaths = claims.map { query in
        query.path.value.map { $0.description }.joined(separator: ".")
      }

      result.append(contentsOf: claimPaths)
    }

    selectedDisclosures =
      claimPaths
      .compactMap { claim in credential.disclosures[claim] }
      .map { DisclosureSelection(disclosure: $0) }
  }

  func sendDisclosures() async throws {
    guard
      let key = try? KeychainService.getOrCreateKey(withTag: .walletKey),
      // TODO: Support DirectPostJwt
      case let .directPost(responseURI: responseUrl) = data.responseMode,
      let credential
    else {
      return
    }

    let clientId = data.client.id.originalClientId

    guard
      let sdJwt = try? createSdJwt(
        with: key,
        credentialJwt: credential.sdJwt,
        clientId: clientId,
        nonce: data.nonce
      ),
      let vpToken = try? createVerifiablePresentationToken(for: sdJwt),
      let body = try? createRequestBody(with: vpToken)
    else {
      throw AppError(reason: "Failed creating request body")
    }

    let response: RedirectUrl = try await NetworkClient.shared.fetch(
      responseUrl,
      method: .post,
      contentType: "application/x-www-form-urlencoded",
      body: body.utf8Data
    )

    guard let redirectUrl = URL(string: response.redirectUri) else {
      return
    }

    await UIApplication.shared.open(redirectUrl)
  }

  private func createRequestBody(with vpToken: VerifiablePresentationToken) throws -> String {
    let token = try JSONEncoder().encode(vpToken.vpToken)
    let payload: [String: String?] = [
      "state": vpToken.state,
      "nonce": vpToken.nonce,
      "vp_token": String(decoding: token, as: UTF8.self),
    ]

    return
      payload
      .compactMapValues { $0 }
      .map { "\($0.key)=\($0.value)" }
      .joined(separator: "&")
  }

  private func createJweResponseBody(with vpToken: VerifiablePresentationToken) throws -> String {
    guard
      let recipientKey = data.clientMetaData?.jwkSet?.keys.first,
      let publicKey = try? recipientKey.toEcPublicKey()
    else {
      throw AppError(reason: "Could not create JWE")
    }

    let jwe = try jwtUtil.encryptJWE(
      payload: vpToken,
      recipientKey: publicKey,
    )

    return "response=\(jwe)"
  }

  private func createVerifiablePresentationToken(
    for sdJwt: String
  ) throws -> VerifiablePresentationToken {
    let id: String = {
      if case let .byDigitalCredentialsQuery(dcql) = data.presentationQuery {
        return dcql.credentials.first?.id.value ?? ""
      }
      return ""
    }()

    return VerifiablePresentationToken(
      state: data.state,
      nonce: data.nonce,
      vpToken: [id: [sdJwt]],
    )
  }

  private func createSdJwt(
    with secKey: SecKey,
    credentialJwt: String,
    clientId: String,
    nonce: String
  ) throws -> String {
    let header = credentialJwt
    let body: [String] = selectedDisclosures.compactMap {
      $0.isSelected ? $0.disclosure.base64 : nil
    }

    let parts = [header] + body
    let sdJwt = parts.joined(separator: "~").appending("~")

    let keyBinding = try createKeyBinding(for: sdJwt, with: secKey, aud: clientId, nonce: nonce)
    return sdJwt + keyBinding
  }

  private func createKeyBinding(
    for sdJwt: String,
    with secKey: SecKey,
    aud: String,
    nonce: String
  ) throws -> String {
    guard let sdJwtData = sdJwt.data(using: .ascii) else {
      throw AppError(reason: "Failed converting sdJwt to Data")
    }
    let hash = SHA256.hash(data: sdJwtData)
    let sdHash = Data(hash).base64URLEncodedString()
    let payload = KeyBinding(
      aud: aud,
      nonce: nonce,
      sdHash: sdHash
    )

    return try jwtUtil.signJWT(with: secKey, payload: payload, headers: ["typ": "kb+jwt"])
  }
}

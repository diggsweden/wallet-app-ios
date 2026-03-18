// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import CryptoKit
import Foundation
import JSONWebSignature
import UIKit
import eudi_lib_sdjwt_swift

@MainActor
@Observable
class PresentationViewModel {
  let url: URL
  let credential: SavedCredential?
  private(set) var requestData: PresentationRequestData?
  private(set) var disclosedSdJwt: SignedSDJWT?
  private(set) var claimsToPresent: [ClaimUiModel] = []
  private let jwtUtil = JwtUtil()

  init(url: URL, credential: SavedCredential?) {
    self.url = url
    self.credential = credential
  }

  func resolveAndMatchClaims() async throws {
    let data = try await OpenId4VpUtil().resolve(url: url)
    self.requestData = data

    guard let credential else {
      throw AppError(reason: "No credential on device")
    }

    let sdJwt = try CompactParser().getSignedSdJwt(serialisedString: credential.compactSerialized)
    guard let disclosedSdJwt = try sdJwt.present(query: data.claimPaths) else {
      throw AppError(reason: "No matching claims")
    }

    self.disclosedSdJwt = disclosedSdJwt
    claimsToPresent = try disclosedSdJwt.toClaimUiModels(displayNames: credential.claimDisplayNames)
  }

  func sendPresentation() async throws {
    guard
      let data = requestData,
      let disclosedSdJwt,
      let key = try? KeychainService.getOrCreateKey(withTag: .walletKey)
    else {
      return
    }

    let sdJwtWithKeyBinding = try await createPresentationSdJwt(
      with: key,
      disclosedSdJwt: disclosedSdJwt,
      clientId: data.clientId,
      nonce: data.nonce
    )

    let vpToken = VerifiablePresentationToken(
      state: data.state,
      nonce: data.nonce,
      vpToken: [data.credentialQueryId: [sdJwtWithKeyBinding]]
    )

    let body = try createRequestBody(with: vpToken)

    let response: RedirectUrl = try await NetworkClient.shared.fetch(
      data.responseUrl,
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
    guard let recipientKey = requestData?.recipientJWK else {
      throw AppError(reason: "Could not create JWE")
    }

    let jwe = try jwtUtil.encryptJwe(
      payload: vpToken,
      recipientKey: recipientKey,
    )

    return "response=\(jwe)"
  }

  private func createPresentationSdJwt(
    with secKey: SecKey,
    disclosedSdJwt: SignedSDJWT,
    clientId: String,
    nonce: String
  ) async throws -> String {
    let sdJwtSerialized = disclosedSdJwt.serialisation
    let keyBindingJwt = try createKeyBinding(
      for: sdJwtSerialized,
      with: secKey,
      aud: clientId,
      nonce: nonce
    )

    return sdJwtSerialized + keyBindingJwt
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
    let sdHash = Data(hash).base64UrlEncodedString()
    let header = DefaultJWSHeaderImpl(algorithm: .ES256, type: "kb+jwt")
    let payload = KeyBindingPayload(
      aud: aud,
      nonce: nonce,
      sdHash: sdHash
    )

    return try jwtUtil.signJwt(with: secKey, payload: payload, header: header)
  }
}

// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import CryptoKit
import Foundation
import JSONWebSignature
import eudi_lib_sdjwt_swift

@MainActor
@Observable
final class PresentationViewModel {
  let url: URL
  let credential: SavedCredential?
  private let jwtUtil = JwtUtil()
  private(set) var phase: PresentationPhase = .loading
  private(set) var requestData: PresentationRequestData?
  private(set) var requiredItems: [PresentationItem] = []
  private(set) var isSending = false
  var optionalItems: [PresentationItem] = []
  var error: ErrorEvent?

  init(url: URL, credential: SavedCredential?) {
    self.url = url
    self.credential = credential
  }

  func resolveAndMatchClaims() async {
    do {
      guard let credential else {
        throw PresentationError.noCredential
      }
      let data = try await OpenId4VpUtil().resolve(url: url)
      self.requestData = data

      let sdJwt = try CompactParser().getSignedSdJwt(serialisedString: credential.compactSerialized)

      let allItems: [PresentationItem] = try data.credentialQueries.compactMap { query in
        guard let disclosed = try sdJwt.present(query: query.claimPaths) else {
          return nil
        }
        let claims = try disclosed.toClaimUiModels(displayNames: credential.claimDisplayNames)
        return PresentationItem(
          id: query.id,
          required: query.required,
          claims: claims,
          disclosedSdJwt: disclosed,
          isSelected: query.required
        )
      }

      if allItems.isEmpty {
        throw PresentationError.noMatchingClaims
      }

      requiredItems = allItems.filter(\.required)
      optionalItems = allItems.filter { !$0.required }
      phase = .ready
    } catch {
      self.error = error.toErrorEvent()
      phase = .error
    }
  }

  func sendPresentation() async -> PresentationResult? {
    isSending = true
    defer { isSending = false }
    do {
      let redirectUrl = try await send()
      return PresentationResult(redirectUrl: redirectUrl)
    } catch {
      self.error = error.toErrorEvent()
      return nil
    }
  }

  private func send() async throws -> URL? {
    guard let data = requestData else {
      throw PresentationError.noRequestData
    }

    let key = try KeychainService.getOrCreateKey(withTag: .walletKey)

    let selectedItems = requiredItems + optionalItems.filter(\.isSelected)

    var vpTokenEntries: [String: [String]] = [:]
    for item in selectedItems {
      let serialized = try createPresentationSdJwt(
        with: key,
        disclosedSdJwt: item.disclosedSdJwt,
        clientId: data.clientId,
        nonce: data.nonce
      )
      vpTokenEntries[item.id] = [serialized]
    }

    let vpToken = VerifiablePresentationToken(
      state: data.state,
      nonce: data.nonce,
      vpToken: vpTokenEntries
    )

    let body = try createRequestBody(with: vpToken)

    let response: RedirectUrl = try await NetworkClient.shared.fetch(
      data.responseUrl,
      method: .post,
      contentType: "application/x-www-form-urlencoded",
      body: body.utf8Data
    )

    return response.redirectUri.flatMap { URL(string: $0) }
  }

  private func createRequestBody(with vpToken: VerifiablePresentationToken) throws -> String {
    let token = try JSONEncoder().encode(vpToken.vpToken)
    let allowed = CharacterSet.urlQueryAllowed.subtracting(.init(charactersIn: "+&="))

    var parts: [String] = []
    if let state = vpToken.state {
      parts.append("state=\(state)")
    }
    parts.append("nonce=\(vpToken.nonce)")
    let vpTokenString = String(decoding: token, as: UTF8.self)
    let encodedVpToken =
      vpTokenString.addingPercentEncoding(withAllowedCharacters: allowed) ?? vpTokenString
    parts.append("vp_token=\(encodedVpToken)")

    return parts.joined(separator: "&")
  }

  private func createJweResponseBody(with vpToken: VerifiablePresentationToken) throws -> String {
    guard let recipientKey = requestData?.recipientJWK else {
      throw PresentationError.jweEncryptionFailed
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
  ) throws -> String {
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
      throw PresentationError.keyBindingEncodingFailed
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

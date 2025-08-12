import CryptoKit
import Foundation
import JOSESwift
import OpenID4VCI
import SiopOpenID4VP
import UIKit

@MainActor
@Observable
class PresentationViewModel {
  let data: ResolvedRequestData.VpTokenData
  let credential: Credential
  var selectedDisclosures: [DisclosureSelection] = []

  init(data: ResolvedRequestData.VpTokenData, credential: Credential) {
    self.data = data
    self.credential = credential
  }

  func matchDisclosures() throws {
    guard case let .byDigitalCredentialsQuery(dcql) = data.presentationQuery else {
      throw AppError(message: "We support only DCQL")
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
      let key = try? KeychainManager.shared.getOrCreateKey(withTag: Constants.bindingKeyTag),
      case let .directPostJWT(responseURI: responseUrl) = data.responseMode
    else {
      return
    }

    let clientId = data.client.id.originalClientId

    guard
      let vpToken = try? createVpToken(with: key, clientId: clientId, nonce: data.nonce),
      let payload = try? createSubmissionPayload(for: vpToken),
      let body = try? createRequestBody(with: payload)
    else {
      throw AppError(message: "Failed creating request body")
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

  private func createRequestBody(with payload: [String: Any]) throws -> String {
    guard
      let recipientKey = data.clientMetaData?.jwkSet?.keys.first,
      let publicKey = try? recipientKey.toEcPublicKey()
    else {
      throw AppError(message: "Could not create JWE")
    }

    let jwe = try JWTUtil.createJWE(
      payload: payload,
      recipientKey: publicKey,
    )

    return "response=\(jwe)"
  }

  private func createSubmissionPayload(for vpToken: String) throws -> [String: Any] {
    let id: String = {
      if case let .byDigitalCredentialsQuery(dcql) = data.presentationQuery {
        return dcql.credentials.first?.id.value ?? ""
      }
      return ""
    }()

    return [
      "state": data.state ?? "",
      "nonce": data.nonce,
      "vp_token": [id: [vpToken]],
    ]
  }

  private func createVpToken(with secKey: SecKey, clientId: String, nonce: String) throws -> String
  {
    let header = credential.sdJwt
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
      throw AppError(message: "Failed converting sdJwt to Data")
    }
    let hash = SHA256.hash(data: sdJwtData)
    let sdHash = Data(hash).base64URLEncodedString()
    let payload: [String: String] = [
      "aud": aud,
      "nonce": nonce,
      "sd_hash": sdHash,
    ]

    return try JWTUtil.createJWT(with: secKey, payload: payload, headerType: "kb+jwt")
  }
}

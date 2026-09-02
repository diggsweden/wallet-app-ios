// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import Foundation

public struct ResolvedPresentation: Sendable {
  public let candidates: [PresentationCandidate]
  public let disclosedSdJwts: [String: String]
  public let responseUrl: URL
  public let clientId: String
  public let nonce: String
  public let state: String?

  public init(
    candidates: [PresentationCandidate],
    disclosedSdJwts: [String: String],
    responseUrl: URL,
    clientId: String,
    nonce: String,
    state: String?,
  ) {
    self.candidates = candidates
    self.disclosedSdJwts = disclosedSdJwts
    self.responseUrl = responseUrl
    self.clientId = clientId
    self.nonce = nonce
    self.state = state
  }
}

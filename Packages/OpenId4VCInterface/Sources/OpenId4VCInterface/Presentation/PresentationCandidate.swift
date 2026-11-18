// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

public struct PresentationCandidate: Identifiable, Sendable {
  public let id: String
  public let required: Bool
  public let credentialUiModel: CredentialUiModel

  public init(id: String, required: Bool, credentialUiModel: CredentialUiModel) {
    self.id = id
    self.required = required
    self.credentialUiModel = credentialUiModel
  }
}

// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import Foundation

typealias IssuerDisplay = SchemaV2.IssuerDisplay
typealias SavedCredential = SchemaV2.SavedCredential
typealias CredentialDisplayData = SchemaV2.CredentialDisplayData

enum CredentialType: String, Codable, Sendable {
  case pid = "urn:eudi:pid:1"
}

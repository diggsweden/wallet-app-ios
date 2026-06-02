// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

public protocol SessionSigningProvider: Sendable {
  func keyId() throws -> String
  func signSessionJwt(keyId: String, nonce: String) throws -> String
}

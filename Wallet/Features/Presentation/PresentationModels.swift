// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import Foundation

struct RedirectUrl: Decodable {
  let redirectUri: String
}

struct DisclosureSelection: Identifiable {
  let id = UUID()
  let disclosure: Disclosure
  var isSelected: Bool = true
}

struct KeyBinding: Codable {
  let aud: String
  let nonce: String
  let sdHash: String
}

struct VerifiablePresentationToken: Codable {
  let state: String?
  let nonce: String
  let vpToken: [String: [String]]
}

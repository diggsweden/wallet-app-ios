// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import Foundation
import Testing

@testable import QRScanner

struct BundleURLSchemesTests {
  @Test
  func `collects schemes across all URL types`() {
    let info: [String: Any] = [
      "CFBundleURLTypes": [
        ["CFBundleURLSchemes": ["scheme-a"]],
        ["CFBundleURLSchemes": ["scheme-b", "scheme-c"]],
      ]
    ]

    #expect(Bundle.urlSchemes(in: info) == ["scheme-a", "scheme-b", "scheme-c"])
  }

  @Test
  func `lowercases schemes`() {
    let info: [String: Any] = ["CFBundleURLTypes": [["CFBundleURLSchemes": ["Scheme-A"]]]]

    #expect(Bundle.urlSchemes(in: info) == ["scheme-a"])
  }

  @Test
  func `skips URL types without schemes`() {
    let info: [String: Any] = [
      "CFBundleURLTypes": [
        ["CFBundleURLName": "se.digg.wallet"],
        ["CFBundleURLSchemes": ["scheme-a"]],
      ]
    ]

    #expect(Bundle.urlSchemes(in: info) == ["scheme-a"])
  }

  @Test
  func `returns no schemes for missing or malformed info`() {
    #expect(Bundle.urlSchemes(in: nil).isEmpty)
    #expect(Bundle.urlSchemes(in: [:]).isEmpty)
    #expect(Bundle.urlSchemes(in: ["CFBundleURLTypes": "not an array"]).isEmpty)
  }
}

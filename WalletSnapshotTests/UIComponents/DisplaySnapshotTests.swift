// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import CredentialInterfaces
import Foundation
import Testing

@testable import WalletDemo

@MainActor
@Suite("Display snapshots", .snapshots(record: .missing))
struct DisplaySnapshotTests {
  @Test("Wallet title")
  func walletTitle() {
    assertThemedSnapshots(of: WalletTitleView())
  }

  @Test("Inline link")
  func inlineLink() {
    let url = URL(string: "https://www.digg.se")!
    assertThemedSnapshots(of: InlineLink("Läs mer om din data", url: url))
  }

  @Test("Issuer display")
  func issuerDisplay() {
    let issuer = IssuerDisplay(name: "Transportstyrelsen", info: nil, imageUrl: nil)
    assertThemedSnapshots(of: IssuerDisplayView(issuerDisplayData: issuer), width: 320)
  }

  @Test("Progress — 25%")
  func progressQuarter() {
    assertThemedSnapshots(of: PrimaryProgressView(value: 0.25), width: 320)
  }

  @Test("Progress — 50%")
  func progressHalf() {
    assertThemedSnapshots(of: PrimaryProgressView(value: 0.5), width: 320)
  }

  @Test("Progress — step 1 of 3")
  func progressThirds() {
    assertThemedSnapshots(of: PrimaryProgressView(value: 1, total: 3), width: 320)
  }
}

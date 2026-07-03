// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import Foundation
import Testing

@testable import WalletDemo

@MainActor
@Suite("Card snapshots", .snapshots(record: .missing))
struct CardSnapshotTests {
  @Test("PID card")
  func pidCard() {
    assertThemedSnapshots(
      of: PidCard(credential: Self.pid).environment(Router()),
      width: 360
    )
  }

  @Test("Document card")
  func documentCard() {
    assertThemedSnapshots(
      of: DocumentCard(credential: Self.document).environment(Router()),
      width: 360
    )
  }

  private static let issuedAt = Date(timeIntervalSince1970: 1_700_000_000)

  private static let pid = SavedCredential(
    issuer: IssuerDisplay(name: "Transportstyrelsen", info: nil, imageUrl: nil),
    compactSerialized: "",
    claimDisplayNames: [:],
    claimsCount: 15,
    issuedAt: issuedAt,
    type: "",
    displayData: nil
  )

  private static let document = SavedCredential(
    issuer: IssuerDisplay(name: "Transportstyrelsen", info: nil, imageUrl: nil),
    compactSerialized: "",
    claimDisplayNames: [:],
    claimsCount: 15,
    issuedAt: issuedAt,
    type: "",
    displayData: CredentialDisplayData(name: "Körkort")
  )
}

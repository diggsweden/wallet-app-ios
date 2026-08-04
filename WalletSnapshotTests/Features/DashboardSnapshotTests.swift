// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import CredentialInterfaces
import Foundation
import SwiftUI
import Testing

@testable import WalletDemo

@MainActor
@Suite("Dashboard snapshots", .snapshots(record: .missing))
struct DashboardSnapshotTests {
  @Test("PID only")
  func pidOnly() {
    assertThemedDeviceSnapshots(
      of: NavigationStack {
        DashboardView(pid: pid, credentials: [])
          .environment(Router())
          .defaultScreenStyle
      }
    )
  }

  @Test("PID and documents")
  func pidAndDocuments() {
    assertThemedDeviceSnapshots(
      of: NavigationStack {
        DashboardView(
          pid: pid,
          credentials: [
            document(named: "Körkort"),
            document(named: "Handlingar"),
            document(named: "Biljetter"),
          ],
        )
        .environment(Router())
        .defaultScreenStyle
      }
    )
  }
}

private extension DashboardSnapshotTests {
  var issuedAt: Date { Date(timeIntervalSince1970: 1_700_000_000) }

  var pid: SavedCredential {
    SavedCredential(
      issuer: IssuerDisplay(name: "Digg", info: "Svensk e-legitimation", imageUrl: nil),
      compactSerialized: "",
      claimDisplayNames: [
        "given_name": "Förnamn",
        "family_name": "Efternamn",
      ],
      claimsCount: 2,
      issuedAt: issuedAt,
      type: CredentialType.pid.rawValue,
      displayData: nil,
    )
  }

  func document(named name: String) -> SavedCredential {
    SavedCredential(
      issuer: IssuerDisplay(name: "Digg", info: "Digital plånbok", imageUrl: nil),
      compactSerialized: "",
      claimDisplayNames: [:],
      claimsCount: 4,
      issuedAt: issuedAt,
      type: "preview.\(name.lowercased())",
      displayData: CredentialDisplayData(name: name),
    )
  }
}

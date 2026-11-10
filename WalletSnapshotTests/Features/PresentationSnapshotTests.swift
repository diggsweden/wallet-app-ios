// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import SwiftUI
import Testing

@testable import UIComponents
@testable import WalletDemo

@MainActor
@Suite("Presentation snapshots", .snapshots(record: .missing))
struct PresentationSnapshotTests {
  @Test("Pin — entry")
  func pinEntry() {
    assertThemedDeviceSnapshots(
      of: PresentationPinView(isLoading: false, onPinEntered: { _ in })
        .environment(ToastViewModel())
    )
  }

  @Test("Pin — loading")
  func pinLoading() {
    assertThemedDeviceSnapshots(
      of: PresentationPinView(isLoading: true, onPinEntered: { _ in })
        .environment(ToastViewModel())
    )
  }

  @Test("Success")
  func success() {
    assertThemedDeviceSnapshots(of: PresentationSuccessView(onDismiss: {}))
  }

  @Test("Review header — without logo")
  func reviewHeaderWithoutLogo() {
    assertThemedSnapshots(
      of: PresentationReviewHeaderView(
        name: Self.verifierName,
        purpose: Self.verifierPurpose,
        onTap: {},
      ),
      width: 360,
    )
  }

  @Test("Review header — with logo")
  func reviewHeaderWithLogo() {
    assertThemedSnapshots(
      of: PresentationReviewHeaderView(
        name: Self.verifierName,
        purpose: Self.verifierPurpose,
        logo: Image(systemName: "car.side.fill"),
        onTap: {},
      ),
      width: 360,
    )
  }

  @Test("Review header — without purpose")
  func reviewHeaderWithoutPurpose() {
    assertThemedSnapshots(
      of: PresentationReviewHeaderView(name: Self.verifierName, onTap: {}),
      width: 360,
    )
  }

  private static let verifierName = "Nordbil Hyrbilar AB"
  private static let verifierPurpose = "Identitets- och körkortskontroll vid biluthyrning."
}

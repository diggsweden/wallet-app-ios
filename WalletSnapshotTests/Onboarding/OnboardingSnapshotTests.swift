// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import Testing
import WalletGateway

@testable import WalletDemo

@MainActor
@Suite("Onboarding snapshots", .snapshots(record: .missing))
struct OnboardingSnapshotTests {
  @Test("Onboarding root — intro")
  func onboardingRoot() {
    assertThemedDeviceSnapshots(of: onboardingRootView)
  }

  @Test("PID")
  func pid() {
    assertThemedSnapshots(
      of: OnboardingPidView { _ in }.withToast,
      width: 360
    )
  }
}

private extension OnboardingSnapshotTests {
  var onboardingRootView: OnboardingRootView {
    OnboardingRootView(
      gatewayApiClient: GatewayApiMock(),
      userSnapshot: UserSnapshot(accountId: nil, credentials: [], pid: nil),
      savePidCredential: { _ in },
      signIn: { _ in },
      onReset: {}
    )
  }
}

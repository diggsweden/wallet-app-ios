// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import SwiftUI

@main
struct WalletApp: App {
  var body: some Scene {
    WindowGroup {
      BootstrapView()
        .withWindowBridge
        .themed
        .withOrientation
        .withToast
    }
  }
}

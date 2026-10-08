// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import DesignSystem
import SDWebImageWebPCoder
import SwiftUI

@main
struct WalletApp: App {
  init() {
    DesignSystem.registerFonts()
    SDImageCodersManager.shared.addCoder(SDImageAWebPCoder.shared)
  }

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

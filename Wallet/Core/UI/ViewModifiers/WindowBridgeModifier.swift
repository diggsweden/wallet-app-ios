// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import SwiftUI
import UIKit

extension EnvironmentValues {
  @Entry var hasBottomSafeArea: Bool = false
}

struct WindowBridgeModifier: ViewModifier {
  @State private var window: UIWindow?
  @State private var hasBottomSafeArea = false

  func body(content: Content) -> some View {
    content
      .background(
        WindowProvider { window in
          guard let window, window !== self.window else {
            return
          }

          self.window = window
          hasBottomSafeArea = window.safeAreaInsets.bottom > 0
        }
      )
      .environment(\.hasBottomSafeArea, hasBottomSafeArea)
  }
}

extension View {
  var withWindowBridge: some View {
    modifier(WindowBridgeModifier())
  }
}

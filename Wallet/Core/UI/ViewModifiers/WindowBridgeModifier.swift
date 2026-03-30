// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import AuthenticationServices
import SwiftUI

extension EnvironmentValues {
  @Entry var authPresentationAnchor: ASPresentationAnchor?
  @Entry var hasBottomSafeArea: Bool = false
}

struct WindowBridgeModifier: ViewModifier {
  @State private var anchor: ASPresentationAnchor?
  @State private var hasBottomSafeArea = false

  func body(content: Content) -> some View {
    content
      .background(
        WindowProvider { window in
          guard let window, window !== anchor else {
            return
          }

          anchor = window
          hasBottomSafeArea = window.safeAreaInsets.bottom > 0
        }
      )
      .environment(\.authPresentationAnchor, anchor)
      .environment(\.hasBottomSafeArea, hasBottomSafeArea)
  }
}

extension View {
  var withWindowBridge: some View {
    modifier(WindowBridgeModifier())
  }
}

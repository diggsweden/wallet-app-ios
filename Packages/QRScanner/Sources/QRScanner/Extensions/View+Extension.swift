// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import SwiftUI

extension View {
  @ContentBuilder
  func hiddenStatusBar() -> some View {
    if #available(iOS 27.0, *) {
      self.toolbarVisibility(.hidden, for: .statusBar)
    } else {
      self.statusBarHidden()
    }
  }
}

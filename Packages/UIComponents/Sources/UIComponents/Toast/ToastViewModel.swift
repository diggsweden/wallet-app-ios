// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import SwiftUI

@Observable
final class ToastViewModel {
  var current: Toast?

  func show(_ toast: Toast) {
    withAnimation(.bouncy(duration: 0.3)) {
      current = toast
    }
  }

  func hide() {
    withAnimation(.smooth) {
      current = nil
    }
  }

  func showError(_ title: String) {
    show(
      Toast(
        type: .error,
        title: title,
      )
    )
  }
}

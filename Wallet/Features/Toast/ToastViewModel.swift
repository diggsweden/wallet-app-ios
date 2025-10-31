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

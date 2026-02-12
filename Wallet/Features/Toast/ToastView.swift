// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import SwiftUI

struct ToastView: View {
  let toast: Toast
  let onTap: () -> Void
  @Environment(\.theme) private var theme

  init(_ toast: Toast, onTap: @escaping () -> Void) {
    self.toast = toast
    self.onTap = onTap
  }

  var body: some View {
    let shape = RoundedRectangle(cornerRadius: theme.cornerRadius)

    VStack(alignment: .trailing, spacing: 12) {
      HStack(alignment: .top, spacing: 20) {
        Image(systemName: icon)
          .font(.system(size: 30))
          .foregroundStyle(accentColor)
        Text(toast.title)
          .textStyle(.h5)
        Button {
          onTap()
        } label: {
          Image(systemName: "x.square")
        }
        .buttonStyle(.plain)
      }
      .foregroundStyle(Theme.light.colors.textPrimary)
    }
    .padding(.vertical, 15)
    .padding(.horizontal, 20)
    .background(background, in: shape)
    .overlay(shape.stroke(accentColor, lineWidth: 1))
    .overlay(alignment: .leading) {
      shape
        .fill(accentColor)
        .mask(
          shape
            .frame(width: 3)
            .frame(maxWidth: .infinity, alignment: .leading)
        )
        .allowsHitTesting(false)
    }
    .accessibilityElement(children: .combine)
    .padding(.horizontal, 32)
  }

  private var icon: String {
    switch toast.type {
      case .info: return "info.circle"
      case .success: return "checkmark.circle"
      case .warning: return "info.triangle"
      case .error: return "exclamationmark.triangle"
    }
  }

  private var background: Color {
    return switch toast.type {
      case .info: theme.colors.info
      case .success: theme.colors.success
      case .warning: theme.colors.warning
      case .error: theme.colors.error
    }
  }

  private var accentColor: Color {
    return switch toast.type {
      case .info: theme.colors.infoInverse
      case .success: theme.colors.successInverse
      case .warning: theme.colors.warningInverse
      case .error: theme.colors.errorInverse
    }
  }
}

#Preview {
  let toasts = [
    Toast(type: .error, title: "Något gick fel! Testa igen och testa igen"),
    Toast(type: .success, title: "Något gick bra!"),
    Toast(type: .info, title: "Lite information"),
    Toast(type: .warning, title: "En varning!"),
  ]
  VStack {
    ForEach(toasts) { ToastView($0) {} }
  }
  .themed
}

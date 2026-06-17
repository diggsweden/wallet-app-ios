// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import SwiftUI

struct SecondaryButton: View {
  let text: String
  let icon: String?
  let maxWidth: CGFloat
  let onClick: () -> Void
  @Environment(\.theme) private var theme
  @Environment(\.isEnabled) private var isEnabled
  @Environment(\.orientation) private var orientation

  init(
    _ text: String,
    icon: String? = nil,
    maxWidth: CGFloat = 360,
    onClick: @escaping () -> Void
  ) {
    self.text = text
    self.icon = icon
    self.maxWidth = maxWidth
    self.onClick = onClick
  }

  var body: some View {
    Button {
      onClick()
    } label: {
      HStack(alignment: .firstTextBaseline, spacing: 4) {
        Text(LocalizedStringKey(text))
        if let icon {
          Image(systemName: icon)
            .accessibilityHidden(true)
        }
      }
      .padding(.vertical, 12)
      .padding(.horizontal, 20)
      .frame(maxWidth: maxWidth)
      .background(
        .white.opacity(isEnabled ? 1 : 0.5),
        in: RoundedRectangle(cornerRadius: theme.cornerRadius)
      )
      .foregroundStyle(theme.colors.primary)  // TODO: Use correct token
    }
    .buttonStyle(.plain)
    .overlay(
      RoundedRectangle(cornerRadius: theme.cornerRadius)
        .stroke(theme.colors.primary, lineWidth: 2)  // TODO: Use correct token
    )
    .padding(.horizontal, 15)
  }
}

#Preview {
  VStack {
    SecondaryButton("WIDTH", maxWidth: 60) {}
    SecondaryButton("TEST", icon: "heart") {}
  }
  .background(.black)
  .themed
}

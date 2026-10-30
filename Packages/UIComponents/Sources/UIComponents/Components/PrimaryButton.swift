// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import DesignSystem
import SwiftUI

public struct PrimaryButton: View {
  let text: LocalizedStringResource
  let icon: String?
  let maxWidth: CGFloat
  let onClick: () -> Void
  @Environment(\.theme) private var theme
  @Environment(\.isEnabled) private var isEnabled

  public init(
    _ text: LocalizedStringResource,
    icon: String? = nil,
    maxWidth: CGFloat = 360,
    onClick: @escaping () -> Void,
  ) {
    self.text = text
    self.icon = icon
    self.maxWidth = maxWidth
    self.onClick = onClick
  }

  public var body: some View {
    Button {
      onClick()
    } label: {
      HStack(alignment: .firstTextBaseline, spacing: 4) {
        Text(text)
        if let icon {
          Image(systemName: icon)
            .accessibilityHidden(true)
        }
      }
      .padding(.vertical, 12)
      .padding(.horizontal, 20)
      .frame(maxWidth: maxWidth)
      .background(
        theme.colors.button.opacity(isEnabled ? 1 : 0.5),
        in: RoundedRectangle(cornerRadius: theme.cornerRadius),
      )
      .foregroundStyle(theme.colors.onPrimary)
    }
    .buttonStyle(.plain)
    .padding(.horizontal, 15)
  }
}

#Preview {
  VStack {
    PrimaryButton("WIDTH", maxWidth: 60) {}
    PrimaryButton("TEST", icon: "heart") {}
  }
  .themed
}

// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import SwiftUI

struct PrimaryBarModel {
  let title: LocalizedStringResource
  let icon: String?
  let accessibilityHint: LocalizedStringResource?
  let action: () -> Void

  init(
    _ title: LocalizedStringResource,
    icon: String? = nil,
    accessibilityHint: LocalizedStringResource? = nil,
    action: @escaping () -> Void,
  ) {
    self.title = title
    self.icon = icon
    self.accessibilityHint = accessibilityHint
    self.action = action
  }
}

struct PrimaryActionBar: ViewModifier {
  static let defaultHorizontalPadding: CGFloat = 16

  let model: PrimaryBarModel?
  let horizontalPadding: CGFloat

  func body(content: Content) -> some View {
    content
      .safeAreaBarIfPossible(edge: .bottom) {
        if let model {
          PrimaryButton(
            model.title,
            icon: model.icon,
            maxWidth: .infinity,
            onClick: model.action,
          )
          .accessibilityHint(model.accessibilityHint.map { Text($0) } ?? Text(verbatim: ""))
          .padding(.horizontal, horizontalPadding)
        }
      }
  }
}

extension View {
  func primaryActionBar(
    _ title: LocalizedStringResource,
    icon: String? = nil,
    accessibilityHint: LocalizedStringResource? = nil,
    horizontalPadding: CGFloat = PrimaryActionBar.defaultHorizontalPadding,
    action: @escaping () -> Void,
  ) -> some View {
    primaryActionBar(
      PrimaryBarModel(
        title,
        icon: icon,
        accessibilityHint: accessibilityHint,
        action: action,
      ),
      horizontalPadding: horizontalPadding,
    )
  }

  func primaryActionBar(
    _ model: PrimaryBarModel?,
    horizontalPadding: CGFloat = PrimaryActionBar.defaultHorizontalPadding,
  ) -> some View {
    modifier(PrimaryActionBar(model: model, horizontalPadding: horizontalPadding))
  }
}

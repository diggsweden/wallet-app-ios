// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import SwiftUI

public struct PrimaryBarModel {
  let title: LocalizedStringResource
  let icon: String?
  let accessibilityHint: LocalizedStringResource?
  let action: () -> Void

  public init(
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

public struct PrimaryActionBar: ViewModifier {
  public static let defaultHorizontalPadding: CGFloat = 40

  let model: PrimaryBarModel?
  let secondaryModel: PrimaryBarModel?
  let horizontalPadding: CGFloat

  public func body(content: Content) -> some View {
    content
      .safeAreaBarIfPossible(edge: .bottom) {
        if model != nil || secondaryModel != nil {
          ViewThatFits(in: .horizontal) {
            HStack(spacing: Constants.buttonSpacing) {
              secondaryButton
              primaryButton
            }

            VStack(spacing: Constants.stackedButtonSpacing) {
              primaryButton
              secondaryButton
            }
          }
          .padding(.horizontal, horizontalPadding)
        }
      }
  }

  @ViewBuilder
  private var primaryButton: some View {
    if let model {
      PrimaryButton(
        model.title,
        icon: model.icon,
        maxWidth: .infinity,
        onClick: model.action,
      )
      .accessibilityHint(model.accessibilityHint.map { Text($0) } ?? Text(verbatim: ""))
    }
  }

  @ViewBuilder
  private var secondaryButton: some View {
    if let secondaryModel {
      SecondaryButton(
        secondaryModel.title,
        icon: secondaryModel.icon,
        maxWidth: .infinity,
        onClick: secondaryModel.action,
      )
      .accessibilityHint(secondaryModel.accessibilityHint.map { Text($0) } ?? Text(verbatim: ""))
    }
  }
}

private extension PrimaryActionBar {
  enum Constants {
    static let buttonSpacing: CGFloat = 10
    static let stackedButtonSpacing: CGFloat = 12
  }
}

extension View {
  public func primaryActionBar(
    _ title: LocalizedStringResource,
    icon: String? = nil,
    accessibilityHint: LocalizedStringResource? = nil,
    horizontalPadding: CGFloat = PrimaryActionBar.defaultHorizontalPadding,
    action: @escaping () -> Void,
  ) -> some View {
    primaryActionBar(
      model: PrimaryBarModel(
        title,
        icon: icon,
        accessibilityHint: accessibilityHint,
        action: action,
      ),
      horizontalPadding: horizontalPadding,
    )
  }

  /// Overload that allows conditional rendering of the `PrimaryActionBar`
  public func primaryActionBar(
    model: PrimaryBarModel?,
    secondaryModel: PrimaryBarModel? = nil,
    horizontalPadding: CGFloat = PrimaryActionBar.defaultHorizontalPadding,
  ) -> some View {
    modifier(
      PrimaryActionBar(
        model: model,
        secondaryModel: secondaryModel,
        horizontalPadding: horizontalPadding,
      )
    )
  }
}

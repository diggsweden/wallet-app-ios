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

public struct PrimaryActionBar<AccessoryView: View>: ViewModifier {
  let model: PrimaryBarModel?
  let secondaryModel: PrimaryBarModel?
  let horizontalPadding: CGFloat
  let accessoryView: AccessoryView

  public func body(content: Content) -> some View {
    content
      .safeAreaBarIfPossible(edge: .bottom) {
        if model != nil || secondaryModel != nil {
          VStack(spacing: Constants.accessoryViewSpacing) {
            accessoryView

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

private enum Constants {
  static let accessoryViewSpacing: CGFloat = 4
  static let buttonSpacing: CGFloat = 10
  static let stackedButtonSpacing: CGFloat = 12
}

extension PrimaryActionBar where AccessoryView == EmptyView {
  public static var defaultHorizontalPadding: CGFloat { 40 }
}

extension View {
  public func primaryActionBar(
    _ title: LocalizedStringResource,
    icon: String? = nil,
    accessibilityHint: LocalizedStringResource? = nil,
    horizontalPadding: CGFloat = PrimaryActionBar<EmptyView>.defaultHorizontalPadding,
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
    horizontalPadding: CGFloat = PrimaryActionBar<EmptyView>.defaultHorizontalPadding,
  ) -> some View {
    primaryActionBar(
      model: model,
      secondaryModel: secondaryModel,
      horizontalPadding: horizontalPadding,
    ) {
      EmptyView()
    }
  }

  public func primaryActionBar<AccessoryView: View>(
    model: PrimaryBarModel?,
    secondaryModel: PrimaryBarModel? = nil,
    horizontalPadding: CGFloat = PrimaryActionBar<EmptyView>.defaultHorizontalPadding,
    @ContentBuilder accessoryView: () -> AccessoryView,
  ) -> some View {
    modifier(
      PrimaryActionBar(
        model: model,
        secondaryModel: secondaryModel,
        horizontalPadding: horizontalPadding,
        accessoryView: accessoryView(),
      )
    )
  }
}

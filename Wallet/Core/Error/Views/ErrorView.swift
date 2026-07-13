// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import SwiftUI

struct ErrorView: View {
  @Environment(\.theme) private var theme
  let model: ViewModel
  @State private var onErrorExpand: Bool = false

  var body: some View {
    VStack(spacing: .zero) {
      Spacer()

      Image(model.imageReference)
        .accessibilityHidden(true)
        .padding(.bottom, Constants.imageBottomPadding)

      titleSubtitleStackView
        .padding(.bottom, Constants.titleSubtitleStackViewBottomPadding)

      Spacer()

      Button {
        onErrorExpand = true
      } label: {
        ExpandErrorView(
          code: model.errorInfo.code ?? "",
          time: model.errorInfo.timestamp ?? ""
        )
        .padding(.bottom, Constants.expandButtonBottomPadding)
      }

      buttonStackView
    }
    .toolbar {
      if let onDismiss = model.onDismiss {
        ToolbarItem(placement: .topBarLeading) {
          Button {
            onDismiss()
          } label: {
            Image(systemName: "xmark")
              .accessibilityLabel("Stäng")
              .accessibilityHint("Använd knappen för att stänga felskärmen")
          }
        }
      }
    }
    .sheet(isPresented: $onErrorExpand) {
      ErrorReportView(info: model.errorInfo)
    }
  }
}

private extension ErrorView {
  enum Constants {
    static let imageBottomPadding: CGFloat = 15
    static let titleSubtitleStackViewBottomPadding: CGFloat = 50
    static let titleSubtitleStackViewOuterSpacing: CGFloat = 7
    static let titleSubtitleStackViewInnerSpacing: CGFloat = 16
    static let buttonStackViewSpacing: CGFloat = 20
    static let horizontalPadding: CGFloat = 15
    static let expandButtonBottomPadding: CGFloat = 16
  }
}

private extension ErrorView {
  var titleSubtitleStackView: some View {
    VStack(alignment: .leading, spacing: Constants.titleSubtitleStackViewOuterSpacing) {
      VStack(alignment: .leading, spacing: Constants.titleSubtitleStackViewInnerSpacing) {
        Text(model.title)
          .textStyle(.h1)

        Text(model.subtitle)
          .textStyle(.body)
      }

      if let linkButton = model.linkButton {
        Button {
          linkButton.action()
        } label: {
          Text(linkButton.label)
            .textStyle(.bodySmall)
            .underline()
        }
        .accessibilityLabel(linkButton.label)
        .accessibilityHint(linkButton.accessibilityHint)
      }
    }
  }

  var buttonStackView: some View {
    VStack(spacing: Constants.buttonStackViewSpacing) {
      PrimaryButton(model.primaryButton.label) {
        model.primaryButton.action()
      }
      .accessibilityLabel(model.primaryButton.label)
      .accessibilityHint(model.primaryButton.accessibilityHint)

      if let secondaryButton = model.secondaryButton {
        SecondaryButton(secondaryButton.label) {
          secondaryButton.action()
        }
        .accessibilityLabel(secondaryButton.label)
        .accessibilityHint(secondaryButton.accessibilityHint)
      }
    }
    .padding(.horizontal, Constants.horizontalPadding)
  }
}

#Preview("Default") {
  ErrorView(model: .defaultPreview)
    .defaultScreenStyle
    .themed
}

#Preview("Default with onDismiss") {
  NavigationStack {
    ErrorView(model: .defaultPreview)
      .defaultScreenStyle
      .themed
  }
}

#Preview("Two Buttons") {
  ErrorView(
    model: .init(
      imageReference: "phoneError",
      title: "Hoppsan! Nånting gick fel",
      subtitle: "Vi kunde inte visa innehållet just nu, försök gärna igen senare.",
      primaryButton: .init(
        label: "Försök igen",
        accessibilityHint: "Använd knappen för att försöka igen",
        action: {}
      ),
      secondaryButton: .init(
        label: "Avbryt",
        accessibilityHint: "Använd knappen för att avbryta",
        action: {}
      ),
      linkButton: .init(
        label: "Få hjälp",
        accessibilityHint: "Använd knappen för att få mer hjälp",
        action: {}
      )
    )
  )
  .defaultScreenStyle
  .themed
}

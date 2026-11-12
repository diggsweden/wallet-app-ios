// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import DesignSystem
import SwiftUI
import UIComponents

struct PresentationVerificationView: View {
  let verifierName: String
  let verifierPurpose: String?
  let isEncrypted: Bool

  @Environment(\.theme) private var theme
  @Environment(\.accessibilityReduceMotion) private var reduceMotion
  @State private var step = 0

  var body: some View {
    SoftEdgeScrollView {
      VStack(spacing: Constants.sectionSpacing) {
        headerView

        VStack(spacing: .zero) {
          rowView(
            label: Text("Tillitsregister"),
            title: Text("Tillitsregistret"),
            description: Text("Den officiella listan som mottagaren kontrolleras mot."),
            checkStep: 1,
            showsConnector: true,
          )

          rowView(
            label: Text("Mottagare"),
            title: Text(verifierName),
            description: verifierDescription,
            checkStep: 3,
            showsConnector: false,
          )
        }
        .padding(.horizontal, Constants.rowsHorizontalPadding)

        if isEncrypted {
          encryptionView
        }
      }
      .padding(.horizontal, Constants.horizontalPadding)
      .padding(.top, Constants.topPadding)
      .padding(.bottom, Constants.bottomPadding)
    }
    .task {
      await animateSteps()
    }
  }
}

private extension PresentationVerificationView {
  enum Constants {
    static let sectionSpacing: CGFloat = 28
    static let headerSpacing: CGFloat = 6
    static let horizontalPadding: CGFloat = 16
    static let subtitleHorizontalPadding: CGFloat = 16
    static let rowsHorizontalPadding: CGFloat = 8
    static let topPadding: CGFloat = 16
    static let bottomPadding: CGFloat = 48
    static let rowSpacing: CGFloat = 16
    static let rowTextSpacing: CGFloat = 4
    static let rowTopPadding: CGFloat = 4
    static let rowBottomPadding: CGFloat = 24
    static let indicatorSize: CGFloat = 32
    static let hiddenIndicatorScale: CGFloat = 0.5
    static let connectorWidth: CGFloat = 2
    static let connectorSpacing: CGFloat = 4
    static let encryptionSpacing: CGFloat = 12
    static let encryptionPadding: CGFloat = 16
    static let cornerRadius: CGFloat = 20
    static let stepCount = 3
    static let stepDelay: Duration = .milliseconds(250)
  }

  func animateSteps() async {
    guard !reduceMotion else {
      step = Constants.stepCount
      return
    }

    while step < Constants.stepCount {
      do {
        try await Task.sleep(for: Constants.stepDelay)
      } catch {
        return
      }

      withAnimation(.smooth) {
        step += 1
      }
    }
  }

  var verifierDescription: Text {
    if let verifierPurpose {
      Text("Registrerad och får be om de här uppgifterna, för syftet: \(verifierPurpose)")
    } else {
      Text("Registrerad och får be om de här uppgifterna.")
    }
  }

  @ContentBuilder
  var headerView: some View {
    VStack(spacing: Constants.headerSpacing) {
      Text("Mottagaren är kontrollerad")
        .textStyle(.h2)
        .accessibilityAddTraits(.isHeader)

      Text("Plånboken kontrollerade mottagaren innan du fick se begäran.")
        .textStyle(.body)
        .foregroundStyle(theme.colors.textInformation)
        .padding(.horizontal, Constants.subtitleHorizontalPadding)
    }
    .multilineTextAlignment(.center)
  }

  func rowView(
    label: Text,
    title: Text,
    description: Text,
    checkStep: Int,
    showsConnector: Bool,
  ) -> some View {
    HStack(alignment: .top, spacing: Constants.rowSpacing) {
      indicatorView(checkStep: checkStep, showsConnector: showsConnector)

      VStack(alignment: .leading, spacing: Constants.rowTextSpacing) {
        label
          .textStyle(.label)
          .foregroundStyle(theme.colors.onSurface)

        title
          .textStyle(.h4)

        description
          .textStyle(.bodySmall)
          .foregroundStyle(theme.colors.textInformation)
      }
      .frame(maxWidth: .infinity, alignment: .leading)
      .padding(.top, Constants.rowTopPadding)
      .padding(.bottom, showsConnector ? Constants.rowBottomPadding : 0)
      .accessibilityElement(children: .combine)
    }
    .fixedSize(horizontal: false, vertical: true)
  }

  func indicatorView(checkStep: Int, showsConnector: Bool) -> some View {
    let isChecked = step >= checkStep
    let isConnectorFilled = step > checkStep

    return VStack(spacing: Constants.connectorSpacing) {
      Image(systemName: "checkmark.circle.fill")
        .font(.system(size: Constants.indicatorSize))
        .symbolRenderingMode(.palette)
        .foregroundStyle(theme.colors.onPrimary, theme.colors.button)
        .scaleEffect(isChecked ? 1 : Constants.hiddenIndicatorScale)
        .opacity(isChecked ? 1 : 0)
        .animation(.bouncy, value: isChecked)
        .accessibilityHidden(true)

      if showsConnector {
        Capsule()
          .fill(theme.colors.primaryVariant)
          .frame(width: Constants.connectorWidth)
          .frame(maxHeight: .infinity)
          .scaleEffect(y: isConnectorFilled ? 1 : 0, anchor: .top)
          .padding(.bottom, Constants.connectorSpacing)
      }
    }
  }

  var encryptionView: some View {
    HStack(spacing: Constants.encryptionSpacing) {
      Image(systemName: "lock.fill")
        .foregroundStyle(theme.colors.button)
        .accessibilityHidden(true)

      Text("Krypterat hela vägen · bara \(verifierName) kan läsa det du delar")
        .textStyle(.bodySmall)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    .padding(Constants.encryptionPadding)
    .background(
      theme.colors.primaryAccent,
      in: RoundedRectangle(cornerRadius: Constants.cornerRadius),
    )
  }
}

#Preview("With purpose, encrypted") {
  PresentationVerificationView(
    verifierName: "Nordbil Hyrbilar AB",
    verifierPurpose: "Identitets- och körkortskontroll vid biluthyrning.",
    isEncrypted: true,
  )
  .themed
}

#Preview("Without purpose, not encrypted") {
  PresentationVerificationView(
    verifierName: "Nordbil Hyrbilar AB",
    verifierPurpose: nil,
    isEncrypted: false,
  )
  .themed
}

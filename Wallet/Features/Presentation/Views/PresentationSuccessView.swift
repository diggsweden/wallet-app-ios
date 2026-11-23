// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import DesignSystem
import SwiftUI
import UIComponents

struct PresentationSuccessView: View {
  let verifierName: String
  let verifierLogo: Image?
  let onShowSharedClaims: () -> Void

  @Environment(\.theme) private var theme
  @Environment(\.accessibilityReduceMotion) private var reduceMotion
  @State private var isChecked = false

  var body: some View {
    SoftEdgeScrollView {
      VStack(spacing: Constants.sectionSpacing) {
        indicatorView

        VStack(spacing: Constants.textSpacing) {
          VStack(spacing: Constants.titleSpacing) {
            Text("Delat med")
              .textStyle(.labelLarge)
              .foregroundStyle(theme.colors.linkAccent)

            Text(verifierName)
              .textStyle(.h2)
          }
          .accessibilityElement(children: .combine)
          .accessibilityAddTraits(.isHeader)

          Text("Fortsätt på enheten där du skannade QR-koden.")
            .textStyle(.body)
            .foregroundStyle(theme.colors.textInformation)
        }
        .multilineTextAlignment(.center)

        showSharedClaimsButtonView
      }
      .padding(.horizontal, Constants.horizontalPadding)
      .containerRelativeFrame(.vertical)
    }
    .scrollBounceBehavior(.basedOnSize)
    .navigationBarBackButtonHidden(true)
    .task {
      await showCheckmark()
    }
  }
}

private extension PresentationSuccessView {
  enum Constants {
    static let sectionSpacing: CGFloat = 24
    static let textSpacing: CGFloat = 12
    static let titleSpacing: CGFloat = 4
    static let horizontalPadding: CGFloat = 32
    static let indicatorSize: CGFloat = 76
    static let checkmarkSize: CGFloat = 36
    static let logoCornerRadius: CGFloat = 22
    static let logoPadding: CGFloat = 12
    static let logoBorderWidth: CGFloat = 1
    static let badgeSize: CGFloat = 32
    static let badgeRingWidth: CGFloat = 4
    static let badgeOffset: CGFloat = 8
    static let hiddenBadgeScale: CGFloat = 0.5
    static let buttonIconSpacing: CGFloat = 8
    static let buttonHorizontalPadding: CGFloat = 16
    static let buttonMinimumHeight: CGFloat = 44
    static let checkmarkDelay: Duration = .milliseconds(300)
  }

  func showCheckmark() async {
    if !reduceMotion {
      do {
        try await Task.sleep(for: Constants.checkmarkDelay)
      } catch {
        return
      }
    }

    isChecked = true
  }

  @ContentBuilder
  var indicatorView: some View {
    if let verifierLogo {
      logoTileView(verifierLogo)
        .overlay(alignment: .bottomTrailing) {
          badgeView
            .offset(x: Constants.badgeOffset, y: Constants.badgeOffset)
        }
    } else {
      Image(systemName: "checkmark")
        .font(.system(size: Constants.checkmarkSize, weight: .semibold))
        .foregroundStyle(theme.colors.onPrimary)
        .drawOnSymbolEffectIfPossible(isActive: !isChecked)
        .animation(reduceMotion ? nil : .snappy, value: isChecked)
        .frame(width: Constants.indicatorSize, height: Constants.indicatorSize)
        .background(theme.colors.linkAccent, in: Circle())
        .accessibilityHidden(true)
    }
  }

  func logoTileView(_ logo: Image) -> some View {
    logo
      .resizable()
      .scaledToFit()
      .padding(Constants.logoPadding)
      .frame(width: Constants.indicatorSize, height: Constants.indicatorSize)
      .background(
        Color.white,
        in: RoundedRectangle(cornerRadius: Constants.logoCornerRadius),
      )
      .overlay {
        RoundedRectangle(cornerRadius: Constants.logoCornerRadius)
          .stroke(theme.colors.strokeDisabled, lineWidth: Constants.logoBorderWidth)
      }
      .accessibilityHidden(true)
  }

  var badgeView: some View {
    Image(systemName: "checkmark.circle.fill")
      .font(.system(size: Constants.badgeSize))
      .symbolRenderingMode(.palette)
      .foregroundStyle(theme.colors.onPrimary, theme.colors.linkAccent)
      .padding(Constants.badgeRingWidth)
      .background(theme.colors.background, in: Circle())
      .scaleEffect(isChecked ? 1 : Constants.hiddenBadgeScale)
      .opacity(isChecked ? 1 : 0)
      .animation(reduceMotion ? nil : .bouncy, value: isChecked)
      .accessibilityHidden(true)
  }

  var showSharedClaimsButtonView: some View {
    Button(action: onShowSharedClaims) {
      HStack(spacing: Constants.buttonIconSpacing) {
        Text("Visa vad som delades")

        Image(systemName: "chevron.right")
          .imageScale(.small)
          .accessibilityHidden(true)
      }
      .textStyle(.bodyMedium)
      .foregroundStyle(theme.colors.linkAccent)
      .padding(.horizontal, Constants.buttonHorizontalPadding)
      .frame(minHeight: Constants.buttonMinimumHeight)
      .contentShape(Rectangle())
    }
    .buttonStyle(.plain)
  }
}

#Preview("Without logo") {
  NavigationStack {
    PresentationSuccessView(
      verifierName: "Nordbil Hyrbilar AB",
      verifierLogo: nil,
      onShowSharedClaims: {},
    )
  }
  .themed
}

#Preview("With logo") {
  NavigationStack {
    PresentationSuccessView(
      verifierName: "Nordbil Hyrbilar AB",
      verifierLogo: Image(systemName: "car.fill"),
      onShowSharedClaims: {},
    )
  }
  .themed
}

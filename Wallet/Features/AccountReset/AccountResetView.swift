// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import DesignSystem
import SwiftUI

struct AccountResetView: View {
  @State private var rotateArrow: Bool = false
  @State private var arrowRotationAngle = Constants.arrowInitialRotationAngle
  @State private var arrowScaleEffect = Constants.arrowDefaultScale

  let onAcknowledge: () -> Void

  @Environment(\.theme) private var theme

  var body: some View {
    // swiftlint:disable:next closure_body_length
    NavigationStack {
      ScrollView {
        VStack(spacing: Constants.parentStackSpacing) {
          illustration
            .padding(.vertical, Constants.illustrationVerticalPadding)

          VStack(spacing: Constants.headingStackSpacing) {
            Text("Din plånbok har återställts")
              .textStyle(.h1)
              .accessibilityAddTraits(.isHeader)

            Text(
              "Appen är under utveckling. En uppdatering gjorde att din plånbok behövde återställas"
            )
            .textStyle(.body)
            .foregroundStyle(theme.colors.textInformation)
          }
          .multilineTextAlignment(.center)

          resetDetails

          Text("Du behöver registrera plånboken igen.")
            .textStyle(.body)
            .multilineTextAlignment(.center)
        }
        .padding(.horizontal, theme.horizontalPadding)
        .padding(.vertical, Constants.contentVerticalPadding)
      }
      .toolbar {
        ToolbarItem(placement: .bottomBar) {
          PrimaryButton(
            "Jag förstår",
            maxWidth: .infinity,
            onClick: onAcknowledge,
          )
          .accessibilityHint("Fortsätt till registreringen")
        }
        .sharedBackgroundVisibilityHiddenIfPossible()
      }
      .background(theme.colors.background.ignoresSafeArea())
      .onAppear {
        withAnimation(
          .easeInOut(duration: Constants.arrowRotationDuration)
            .delay(Constants.arrowRotationDelay)
        ) {
          arrowRotationAngle += Constants.arrowRotationDegrees
        }

        withAnimation(
          .spring(duration: Constants.arrowScaleDuration)
            .delay(Constants.arrowScaleDelay)
        ) {
          arrowScaleEffect = Constants.arrowExpandedScale
        } completion: {
          withAnimation(.spring(duration: Constants.arrowScaleDuration)) {
            arrowScaleEffect = Constants.arrowDefaultScale
          }
        }
      }
    }
  }
}

private extension AccountResetView {
  enum Constants {
    static let parentStackSpacing: CGFloat = 28
    static let illustrationVerticalPadding: CGFloat = 28
    static let headingStackSpacing: CGFloat = 16
    static let contentVerticalPadding: CGFloat = 32
    static let illustrationSize: CGFloat = 112
    static let arrowSize: CGFloat = 40
    static let arrowBorderWidth: CGFloat = 4
    static let arrowHorizontalOffset: CGFloat = 40
    static let arrowVerticalOffset: CGFloat = 32
    static let arrowInitialRotationAngle: Double = 0
    static let arrowRotationDegrees: Double = 360
    static let arrowRotationDuration: Double = 0.8
    static let arrowRotationDelay: Double = 0.3
    static let arrowDefaultScale: Double = 1
    static let arrowExpandedScale: Double = 1.2
    static let arrowScaleDuration: Double = 0.3
    static let arrowScaleDelay: Double = 0.9
    static let detailsStackSpacing: CGFloat = 16
    static let detailsTextSpacing: CGFloat = 8
    static let detailsPadding: CGFloat = 20
    static let detailsCornerRadius: CGFloat = 20
  }

  var illustration: some View {
    Image(systemName: "wallet.bifold")
      .textStyle(.h1)
      .foregroundStyle(theme.colors.onSurface)
      .background {
        Circle()
          .foregroundStyle(theme.colors.primaryAccent)
          .frame(
            width: Constants.illustrationSize,
            height: Constants.illustrationSize,
          )
      }
      .overlay {
        Image(systemName: "arrow.clockwise")
          .textStyle(.bodyLarge)
          .foregroundStyle(theme.colors.onPrimary)
          .frame(
            width: Constants.arrowSize,
            height: Constants.arrowSize,
          )
          .rotationEffect(.degrees(arrowRotationAngle))
          .scaleEffect(arrowScaleEffect)
          .background(theme.colors.button, in: Circle())
          .overlay {
            Circle()
              .stroke(
                theme.colors.background,
                lineWidth: Constants.arrowBorderWidth,
              )
          }
          .offset(
            x: Constants.arrowHorizontalOffset,
            y: Constants.arrowVerticalOffset,
          )
      }
      .accessibilityHidden(true)
  }

  var resetDetails: some View {
    HStack(alignment: .top, spacing: Constants.detailsStackSpacing) {
      Image(systemName: "iphone")
        .textStyle(.h2)
        .foregroundStyle(theme.colors.onSurface)
        .accessibilityHidden(true)

      VStack(alignment: .leading, spacing: Constants.detailsTextSpacing) {
        Text("Borttaget från den här enheten")
          .textStyle(.h5)

        Text("Dina uppgifter och dokument har raderats.")
          .textStyle(.bodySmall)
          .foregroundStyle(theme.colors.onSurface)
      }
      .frame(maxWidth: .infinity, alignment: .leading)
    }
    .padding(Constants.detailsPadding)
    .background(
      theme.colors.primaryAccent,
      in: RoundedRectangle(cornerRadius: Constants.detailsCornerRadius),
    )
    .accessibilityElement(children: .combine)
  }
}

#Preview {
  AccountResetView(onAcknowledge: {})
    .themed
}

// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import SwiftUI
import WalletMacrosClient

struct WelcomeScreen: View {
  let onComplete: () -> Void

  @Environment(\.theme) private var theme
  @Environment(\.colorScheme) private var colorScheme
  @Environment(\.orientation) private var orientation

  private let appVersion: String = "App version: \(Bundle.main.fullVersion)"
  private var titleColor: Color {
    colorScheme == .dark ? BrandColors.brown.25 : BrandColors.brown.100
  }

  var body: some View {
    VStack(alignment: .center) {
      Image(.welcome)
        .resizable()
        .scaleEffect(1.2)
        .scaledToFit()
        .frame(maxWidth: orientation.isLandscape ? 300 : .infinity)
        .padding(.top, orientation.isLandscape ? 0 : 28)

      Spacer()

      VStack(spacing: 2) {
        Text("Plånboken")
          .font(.custom("Ubuntu-Medium", size: 40, relativeTo: .largeTitle))
          .lineHeightIfAvailable(multiple: 1.2)
        Text("Din data, ditt val")
          .font(.custom("Ubuntu-Medium", size: 24, relativeTo: .title))
          .textStyle(.h2)
      }
      .foregroundStyle(titleColor)
      .padding(.bottom, orientation.isLandscape ? 12 : 55)

      PrimaryButton("Kom igång med plånboken") {
        onComplete()
      }
      .padding(.horizontal, 30)
      .padding(.bottom, 24)

      Button {
        UIPasteboard.general.string = appVersion
        UINotificationFeedbackGenerator()
          .notificationOccurred(.success)
      } label: {
        HStack {
          Text(appVersion)
            .textStyle(.caption)
            .textSelection(.enabled)
          Image(systemName: "doc.on.doc")
            .font(.footnote)
        }
      }
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .toolbar {
      ToolbarItem(placement: .principal) {
        Image(.euWalletLogo)
          .resizable()
          .scaledToFit()
          .frame(maxHeight: orientation.isLandscape ? 30 : 45)
      }
    }
    .navigationBarTitleDisplayMode(.inline)
  }
}

#Preview {
  WelcomeScreen {}
    .withOrientation
    .themed
    .padding()
}

// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import SwiftUI
import WalletMacros

struct WelcomeScreen: View {
  let onComplete: () -> Void

  @Environment(\.theme) private var theme
  @Environment(\.colorScheme) private var colorScheme
  @Environment(\.orientation) private var orientation

  private let appVersion: String = "App version: \(Bundle.main.fullVersion)"

  var body: some View {
    VStack(alignment: .center) {
      heroImage

      Spacer()

      titleSection

      PrimaryButton("Kom igång med plånboken") {
        onComplete()
      }
      .padding(.horizontal, 24)
      .padding(.bottom, 24)

      versionButton
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .toolbar {
      ToolbarItem(placement: .principal) {
        Image(.euWalletLogo)
          .resizable()
          .scaledToFit()
          .frame(maxHeight: orientation.isLandscape ? 30 : 45)
          .accessibilityHidden(true)
      }
    }
    .navigationBarTitleDisplayMode(.inline)
  }

  private var heroImage: some View {
    Image(.welcome)
      .resizable()
      .scaleEffect(1.2)
      .scaledToFit()
      .frame(maxWidth: orientation.isLandscape ? 300 : .infinity)
      .padding(.top, orientation.isLandscape ? 0 : 28)
      .accessibilityHidden(true)
  }

  private var titleSection: some View {
    WalletTitleView()
      .padding(.bottom, orientation.isLandscape ? 12 : 55)
  }

  private var versionButton: some View {
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
          .accessibilityHidden(true)
      }
    }
  }
}

#Preview {
  WelcomeScreen {}
    .withOrientation
    .themed
    .padding()
}

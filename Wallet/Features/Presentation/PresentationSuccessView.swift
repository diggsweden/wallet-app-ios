// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import SwiftUI

struct PresentationSuccessView: View {
  let onDismiss: () -> Void
  @Environment(\.theme) private var theme

  var body: some View {
    VStack(spacing: 50) {
      Text("Nu är det klart")
        .textStyle(.h1)
        .padding(.top, 50)

      Image(.presentationSuccess)
        .resizable()
        .frame(width: 180, height: 180)
        .foregroundStyle(theme.colors.linkPrimary)

      Spacer()

      PrimaryButton("Gå tillbaka") {
        onDismiss()
      }
    }
    .navigationBarBackButtonHidden(true)
  }
}

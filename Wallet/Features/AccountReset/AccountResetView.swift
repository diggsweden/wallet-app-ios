// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import DesignSystem
import SwiftUI

struct AccountResetView: View {
  let onAcknowledge: () -> Void

  @Environment(\.theme) private var theme

  var body: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 20) {
        Text("Din plånbok har återställts 🔥")
          .textStyle(.h2)
          .accessibilityAddTraits(.isHeader)

        Text(
          "Appen är under utveckling. En uppdatering gjorde att din plånbok behövde återställas."
        )
        .textStyle(.body)

        Text("Dina uppgifter och dokument har tagits bort från den här enheten.")
          .textStyle(.body)

        Text("Du behöver registrera plånboken igen.")
          .textStyle(.body)
      }
      .frame(maxWidth: .infinity, alignment: .leading)
      .padding(24)
    }
    .toolbar {
      ToolbarItem(placement: .bottomBar) {
        PrimaryButton(
          "Jag förstår",
          maxWidth: .infinity,
        ) {
          onAcknowledge()
        }
      }
      .sharedBackgroundVisibilityHiddenIfPossible()
    }
    .background(theme.colors.backgroundPage)
  }
}

#Preview {
  AccountResetView(onAcknowledge: {})
}

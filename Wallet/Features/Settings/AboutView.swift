// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import DesignSystem
import SwiftUI

struct AboutView: View {
  @Environment(\.theme) private var theme

  var body: some View {
    List {
      HStack {
        Label {
          Text("Version")
            .textStyle(.body)
            .foregroundStyle(theme.colors.textPrimary)
        } icon: {
          Image(systemName: "number")
            .foregroundStyle(theme.colors.linkPrimary)
        }
        Spacer()
        Text(Bundle.main.displayVersion)
          .textStyle(.bodySmall)
          .foregroundStyle(.gray)
      }
    }
    .navigationTitle("Om appen")
    .navigationBarTitleDisplayMode(.inline)
  }
}

#Preview {
  NavigationStack {
    AboutView()
  }
  .themed
}

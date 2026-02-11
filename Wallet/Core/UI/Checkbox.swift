// SPDX-FileCopyrightText: 2026 diggsweden/wallet-app-ios
//
// SPDX-License-Identifier: EUPL-1.2

import SwiftUI

struct Checkbox: View {
  @Binding var isOn: Bool
  @Environment(\.theme) private var theme

  var body: some View {
    Button {
      isOn.toggle()
    } label: {
      RoundedRectangle(cornerRadius: 2)
        .fill(Color.clear)
        .stroke(theme.colors.linkPrimary, lineWidth: 2)
        .overlay {
          if isOn {
            Image(systemName: "checkmark")
              .resizable()
              .bold()
              .foregroundStyle(theme.colors.linkPrimary)
              .padding(4)
          }
        }
        .frame(width: 18, height: 18)
    }
    .buttonStyle(.plain)
  }
}

#Preview {
  @Previewable @State var isOn = true
  VStack {
    Checkbox(isOn: $isOn)
  }
  .frame(maxWidth: .infinity, maxHeight: .infinity).themed
}

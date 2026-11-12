// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import SwiftUI

public struct CloseButtonView: View {
  private let action: () -> Void

  public init(action: @escaping () -> Void) {
    self.action = action
  }

  public var body: some View {
    Group {
      if #available(iOS 26.0, *) {
        Button(role: .close, action: action)
      } else {
        Button(action: action) {
          Image(systemName: "xmark")
        }
      }
    }
    .accessibilityLabel("Stäng")
  }
}

#Preview {
  CloseButtonView {}
}

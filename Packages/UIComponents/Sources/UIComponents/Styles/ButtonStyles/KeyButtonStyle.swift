// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import SwiftUI

struct KeyButtonStyle: ButtonStyle {
  let background: Color
  let highlight: Color

  func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .frame(width: Constants.keySize, height: Constants.keySize)
      .background(background, in: Circle())
      .overlay {
        Circle()
          .fill(highlight.opacity(configuration.isPressed ? Constants.highlightOpacity : 0))
      }
      .contentShape(Circle())
      .animation(
        configuration.isPressed ? nil : .easeOut(duration: Constants.releaseDuration),
        value: configuration.isPressed,
      )
  }
}

private extension KeyButtonStyle {
  enum Constants {
    static let keySize: CGFloat = 72
    static let highlightOpacity: CGFloat = 0.15
    static let releaseDuration: CGFloat = 0.3
  }
}

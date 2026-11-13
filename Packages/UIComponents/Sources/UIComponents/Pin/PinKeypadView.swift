// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import DesignSystem
import SwiftUI

private struct T9Key: Identifiable, Hashable {
  let digit: Character
  let letters: String
  var id: Character { digit }
}

struct PinKeypadView: View {
  let submitLabel: LocalizedStringResource
  let isDeleteEnabled: Bool
  let isSubmitEnabled: Bool
  let onTapDigit: (Character) -> Void
  let onTapDelete: () -> Void
  let onTapSubmit: () -> Void

  @Environment(\.theme) private var theme
  @Environment(\.dynamicTypeSize) private var dynamicTypeSize
  @Environment(\.orientation) private var orientation
  @State private var tapFeedback = false

  private let digitRows: [[T9Key]] = [
    [
      .init(digit: "1", letters: ""),
      .init(digit: "2", letters: "ABC"),
      .init(digit: "3", letters: "DEF"),
    ],
    [
      .init(digit: "4", letters: "GHI"),
      .init(digit: "5", letters: "JKL"),
      .init(digit: "6", letters: "MNO"),
    ],
    [
      .init(digit: "7", letters: "PQRS"),
      .init(digit: "8", letters: "TUV"),
      .init(digit: "9", letters: "WXYZ"),
    ],
  ]

  private let zeroKey = T9Key(digit: "0", letters: "")

  var body: some View {
    Grid(
      horizontalSpacing: Constants.horizontalSpacing,
      verticalSpacing: orientation.isLandscape
        ? Constants.landscapeVerticalSpacing : Constants.verticalSpacing,
    ) {
      ForEach(digitRows, id: \.self) { row in
        GridRow {
          ForEach(row) { key in
            digitButtonView(for: key)
          }
        }
      }

      GridRow {
        deleteButtonView
        digitButtonView(for: zeroKey)
        submitButtonView
      }
    }
    .sensoryFeedback(.impact, trigger: tapFeedback)
  }
}

private extension PinKeypadView {
  enum Constants {
    static let horizontalSpacing: CGFloat = 24
    static let verticalSpacing: CGFloat = 16
    static let landscapeVerticalSpacing: CGFloat = 8
    static let lettersSpacing: CGFloat = 2
    static let iconSize: CGFloat = 22
    static let disabledOpacity: CGFloat = 0.5
    static let keyBackgroundOpacity: CGFloat = 0.05
  }

  func digitButtonView(for key: T9Key) -> some View {
    Button {
      onTapDigit(key.digit)
      tapFeedback.toggle()
    } label: {
      VStack(spacing: Constants.lettersSpacing) {
        Text(String(key.digit))
          .textStyle(.h2)
          .foregroundStyle(theme.colors.textPrimary)

        if dynamicTypeSize <= .xLarge {
          Text(key.letters)
            .textStyle(.caption)
            .foregroundStyle(theme.colors.textInformation)
        }
      }
      .dynamicTypeSize(...DynamicTypeSize.accessibility1)
    }
    .buttonStyle(
      KeyButtonStyle(
        background: theme.colors.textPrimary.opacity(Constants.keyBackgroundOpacity),
        highlight: theme.colors.textPrimary,
      )
    )
    .accessibilityLabel(Text(String(key.digit)))
  }

  var deleteButtonView: some View {
    Button {
      onTapDelete()
      tapFeedback.toggle()
    } label: {
      Image(systemName: "delete.backward")
        .font(.system(size: Constants.iconSize))
        .foregroundStyle(isDeleteEnabled ? theme.colors.textPrimary : theme.colors.iconDisabled)
    }
    .buttonStyle(KeyButtonStyle(background: .clear, highlight: theme.colors.textPrimary))
    .disabled(!isDeleteEnabled)
    .accessibilityLabel("Radera")
  }

  var submitButtonView: some View {
    Button {
      onTapSubmit()
      tapFeedback.toggle()
    } label: {
      Image(systemName: "arrow.right")
        .font(.system(size: Constants.iconSize, weight: .semibold))
        .foregroundStyle(theme.colors.onPrimary)
    }
    .buttonStyle(
      KeyButtonStyle(
        background: theme.colors.button.opacity(isSubmitEnabled ? 1 : Constants.disabledOpacity),
        highlight: theme.colors.onPrimary,
      )
    )
    .disabled(!isSubmitEnabled)
    .animation(.snappy, value: isSubmitEnabled)
    .accessibilityLabel(Text(submitLabel))
  }
}

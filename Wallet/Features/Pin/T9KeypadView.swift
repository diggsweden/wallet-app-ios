// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import SwiftUI

fileprivate struct T9Key: Identifiable, Hashable {
  let digit: Character
  let letters: String
  var id: Character { digit }
}

struct T9KeypadView: View {
  let onTapDigit: (Character) -> Void
  let clearButtonDisabled: Bool
  let onClear: () -> Void

  @Environment(\.theme) private var theme
  @Environment(\.dynamicTypeSize) private var dynamicType
  @Environment(\.orientation) private var orientation

  @State private var onTapFeedback: Bool = false

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
    [.init(digit: "0", letters: "")],
  ]

  var body: some View {
    let verticalSpacing = orientation.isLandscape ? 12.0 : 20.0
    Grid(horizontalSpacing: 30, verticalSpacing: verticalSpacing) {
      ForEach(digitRows, id: \.self) { row in
        GridRow {
          ForEach(row) { key in
            if row.count == 1 {
              clearButton
              keyButton(for: key)
            } else {
              keyButton(for: key)
            }
          }
        }
      }
    }
    .sensoryFeedback(.impact, trigger: onTapFeedback)
  }

  private var clearButton: some View {
    Button {
      onClear()
      onTapFeedback.toggle()
    } label: {
      Image(systemName: "delete.backward")
        .font(.system(size: 22))
        .foregroundStyle(clearButtonDisabled ? theme.colors.iconDisabled : theme.colors.textPrimary)
    }
    .buttonStyle(.plain)
    .disabled(clearButtonDisabled)
  }

  @ViewBuilder
  var shape: some View {
    if orientation.isLandscape {
      Circle()
    } else {
      Capsule()
    }
  }

  private func keyButton(for key: T9Key) -> some View {
    let shape = Capsule()

    return Button {
      onTapDigit(key.digit)
      onTapFeedback.toggle()
    } label: {
      VStack(spacing: 2) {
        Text(String(key.digit))
          .textStyle(.h2)
          .foregroundStyle(theme.colors.linkPrimary)
        if dynamicType <= .xLarge {
          Text(key.letters)
            .textStyle(.caption)
        }
      }
      .frame(width: 80, height: 50)
      .background(theme.colors.surface, in: shape)
      .contentShape(shape)
    }
  }
}

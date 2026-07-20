// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import SwiftUI

struct ExpandErrorView: View {
  let code: String
  let time: String

  var body: some View {
    HStack(spacing: Constants.spacing) {
      Circle()
        .frame(width: Constants.indicatorOuterSize)
        .opacity(Constants.indicatorOpacity)
        .foregroundStyle(.red)
        .overlay {
          Circle()
            .frame(width: Constants.indicatorInnerSize)
            .foregroundStyle(.red)
        }

      Text(code)
        .textStyle(.bodySmall)
      Spacer()

      HStack(spacing: Constants.timeSpacing) {
        Text(time)
        Image(systemName: "chevron.up")
          .accessibilityHidden(true)
      }
      .textStyle(.caption)
      .foregroundStyle(.gray)
    }
    .padding(Constants.contentPadding)
    .glassEffectIfPossible()
    .padding(.horizontal, Constants.horizontalPadding)
  }
}

private extension ExpandErrorView {
  enum Constants {
    static let spacing: CGFloat = 8
    static let contentPadding: CGFloat = 12
    static let horizontalPadding: CGFloat = 15
    static let indicatorOuterSize: CGFloat = 12
    static let indicatorInnerSize: CGFloat = 6
    static let indicatorOpacity: Double = 0.2
    static let timeSpacing: CGFloat = 4
  }
}

#Preview {
  ExpandErrorView(code: "SERVER_ERROR_500", time: "14:32:03")
    .themed
}

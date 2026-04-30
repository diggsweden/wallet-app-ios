// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import SwiftUI

struct DotsLoadingView: View {
  @State private var dotCount = 0

  private let timer = Timer.publish(every: 0.2, on: .main, in: .common).autoconnect()

  var body: some View {
    Text(String(repeating: ".", count: dotCount))
      .textStyle(.bodyLarge)
      .frame(width: 24, alignment: .leading)
      .onReceive(timer) { _ in
        dotCount = (dotCount + 1) % 4
      }
  }
}

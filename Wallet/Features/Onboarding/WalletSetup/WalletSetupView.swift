// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import SwiftUI

struct WalletSetupView: View {
  let viewModel: WalletSetupViewModel

  var body: some View {
    VStack(spacing: 16) {
      switch viewModel.state {
        case .idle:
          Text("Förbereder...")

        case .working(let step):
          Text(step.label)
          ProgressView()

        case .failed(let step, let error):
          Text("Något gick fel vid \(step.label.lowercased())")
          Text(error.localizedDescription)
            .font(.caption)
            .foregroundStyle(.secondary)
          Button("Försök igen") {
            Task { await viewModel.retry() }
          }

        case .complete:
          Text("Klart!")
      }
    }
    .task { await viewModel.setup() }
  }
}

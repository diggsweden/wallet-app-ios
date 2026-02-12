// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import OpenID4VP
import SwiftUI

struct PresentationView: View {
  @State private var viewModel: PresentationViewModel
  @Environment(Router.self) private var router
  @Environment(\.theme) private var theme

  init(vpTokenData: ResolvedRequestData.VpTokenData, credential: Credential?) {
    _viewModel = State(
      wrappedValue: .init(data: vpTokenData, credential: credential)
    )
  }

  var body: some View {
    if viewModel.credential != nil {
      presentView
    } else {
      errorView
    }
  }

  private var presentView: some View {
    GeometryReader { proxy in
      ScrollView {
        VStack(spacing: 30) {
          Text("Vill du dela följande data?").textStyle(.h2)

          CredentialView(disclosures: viewModel.selectedDisclosures.map(\.disclosure))

          Spacer()

          PrimaryButton("Dela", icon: "paperplane") {
            Task {
              try? await viewModel.sendDisclosures()
              router.pop()
            }
          }
        }
        .frame(
          maxWidth: .infinity,
          minHeight: proxy.size.height,
          alignment: .top
        )
      }
      .navigationTitle("Dela attribut")
      .navigationBarTitleDisplayMode(.inline)
    }
    .task {
      try? viewModel.matchDisclosures()
    }
  }

  private var errorView: some View {
    VStack(spacing: 24) {
      Text("Hittade ingen ID-handling!")
        .foregroundStyle(Color.red)
      PrimaryButton("Gå tillbaka") {
        router.pop()
      }
    }
  }
}

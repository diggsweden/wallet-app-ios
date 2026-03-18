// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import SwiftUI

struct PresentationView: View {
  @State private var viewModel: PresentationViewModel
  @Environment(Router.self) private var router
  @Environment(\.theme) private var theme

  init(url: URL, credential: SavedCredential?) {
    _viewModel = State(
      wrappedValue: .init(url: url, credential: credential)
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

          CredentialView(claims: viewModel.claimsToPresent)

          Spacer()

          PrimaryButton("Dela", icon: "paperplane") {
            Task {
              try? await viewModel.sendPresentation()
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
      try? await viewModel.resolveAndMatchClaims()
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

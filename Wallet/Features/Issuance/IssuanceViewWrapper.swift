// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import SwiftUI

struct IssuanceViewWrapper: View {
  let credentialOfferUri: String
  let gatewayApiClient: GatewayApi
  let onSave: (SavedCredential) async -> Void

  var body: some View {
    GeometryReader { proxy in
      ScrollView {
        IssuanceView(
          credentialOfferUri: credentialOfferUri,
          gatewayApiClient: gatewayApiClient,
          onSave: onSave
        )
        .frame(
          maxWidth: .infinity,
          minHeight: proxy.size.height,
          alignment: .top
        )
      }
      .navigationTitle("Hämta attributsintyg")
      .navigationBarTitleDisplayMode(.inline)
    }
  }
}

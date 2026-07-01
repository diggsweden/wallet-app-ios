// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import CredentialInterfaces
import SwiftAccessMechanism
import SwiftUI
import WalletGatewayInterface

struct IssuanceViewWrapper: View {
  let credentialOfferUri: String
  let gatewayApiClient: any GatewayApi & HSMTransport
  let onSave: (SavedCredential) async throws -> Void

  var body: some View {
    GeometryReader { proxy in
      ScrollView {
        IssuanceView(
          credentialOfferUri: credentialOfferUri,
          gatewayApiClient: gatewayApiClient,
          onSaveCredential: onSave
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

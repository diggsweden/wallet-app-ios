// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import CredentialInterfaces
import DesignSystem
import SwiftAccessMechanism
import SwiftUI
import User
import WalletGatewayInterface

struct IssuanceViewWrapper: View {
  @Environment(\.theme) private var theme

  let credentialOfferUri: String
  let gatewayApiClient: any GatewayApi & HSMTransport
  let hsmServerParameters: HsmServerParameters?
  let onSave: (SavedCredential) async throws -> Void

  var body: some View {
    GeometryReader { proxy in
      ScrollView {
        IssuanceView(
          credentialOfferUri: credentialOfferUri,
          gatewayApiClient: gatewayApiClient,
          hsmServerParameters: hsmServerParameters,
          onSaveCredential: onSave,
        )
        .padding(.horizontal, theme.horizontalPadding)
        .frame(
          maxWidth: .infinity,
          minHeight: proxy.size.height,
          alignment: .top,
        )
      }
      .navigationTitle("Begär attributsintyg")
      .navigationBarTitleDisplayMode(.inline)
    }
  }
}

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
  let actions: IssuanceActions

  var body: some View {
    SoftEdgeScrollView {
      IssuanceView(
        credentialOfferUri: credentialOfferUri,
        gatewayApiClient: gatewayApiClient,
        hsmServerParameters: hsmServerParameters,
        actions: actions,
      )
      .padding(.horizontal, theme.horizontalPadding)
    }
    .navigationTitle("Begär attributsintyg")
    .navigationBarTitleDisplayMode(.inline)
    .navigationBarBackButtonHidden()
  }
}

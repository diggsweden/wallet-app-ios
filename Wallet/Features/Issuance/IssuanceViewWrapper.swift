// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import CredentialInterfaces
import SwiftAccessMechanism
import SwiftUI
import User
import WalletGatewayInterface

struct IssuanceViewWrapper: View {
  let credentialOfferUri: String
  let gatewayApiClient: any GatewayApi & HSMTransport
  let hsmServerParameters: HsmServerParameters?
  let actions: IssuanceActions

  var body: some View {
    ScrollView {
      IssuanceView(
        credentialOfferUri: credentialOfferUri,
        gatewayApiClient: gatewayApiClient,
        hsmServerParameters: hsmServerParameters,
        actions: actions,
      )
    }
    .navigationTitle("Begär attributsintyg")
    .navigationBarTitleDisplayMode(.inline)
    .navigationBarBackButtonHidden()
  }
}

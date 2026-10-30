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
  @State private var viewModel: IssuanceViewModel

  init(
    credentialOfferUri: String,
    gatewayApiClient: any GatewayApi & HSMTransport,
    hsmServerParameters: HsmServerParameters?,
    actions: IssuanceActions,
  ) {
    _viewModel = State(
      wrappedValue: .init(
        credentialOfferUri: credentialOfferUri,
        gatewayApiClient: gatewayApiClient,
        hsmServerParameters: hsmServerParameters,
        actions: actions,
      )
    )
  }

  var body: some View {
    SoftEdgeScrollView {
      IssuanceView(viewModel: viewModel)
        .padding(.horizontal, theme.horizontalPadding)
    }
    .issuanceActionBar(viewModel)
    .navigationTitle("Begär attributsintyg")
    .navigationBarTitleDisplayMode(.inline)
    .navigationBarBackButtonHidden()
  }
}

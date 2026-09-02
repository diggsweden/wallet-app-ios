// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import CredentialInterfaces
import Foundation
import OpenID4VCI
import OpenId4VCInterface
import SdJwtClaims
import eudi_lib_sdjwt_swift

extension OpenId4VCInterface.IssuedCredential {
  init(
    compactSdJwt: String,
    configuration: SdJwtVcFormat.CredentialConfiguration,
    issuer: Display?,
    claimDisplayNames: [String: String],
  ) throws {
    let sdJwt = try CompactParser().getSignedSdJwt(serialisedString: compactSdJwt)
    let claims = try sdJwt.toClaimUiModels(displayNames: claimDisplayNames)

    self.init(
      credential: SavedCredential(
        issuer: IssuerDisplay(
          name: issuer?.name ?? "",
          info: issuer?.description,
          imageUrl: issuer?.logo?.uri,
        ),
        compactSerialized: compactSdJwt,
        claimDisplayNames: claimDisplayNames,
        claimsCount: claims.count,
        issuedAt: .now,
        type: configuration.vct ?? "",
        displayData: CredentialDisplayData(
          name: configuration.credentialMetadata?.display.first?.name
        ),
      ),
      claims: claims,
    )
  }
}

// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import CredentialInterfaces
import Foundation

extension CurrentSchema.SavedCredential {
  init(_ credential: CredentialInterfaces.SavedCredential) {
    self.init(
      issuer: CurrentSchema.IssuerDisplay(credential.issuer),
      compactSerialized: credential.compactSerialized,
      claimDisplayNames: credential.claimDisplayNames,
      claimsCount: credential.claimsCount,
      issuedAt: credential.issuedAt,
      type: credential.type,
      displayData: credential.displayData.map { CurrentSchema.CredentialDisplayData($0) }
    )
  }

  func toDomain() -> CredentialInterfaces.SavedCredential {
    CredentialInterfaces.SavedCredential(
      issuer: issuer.toDomain(),
      compactSerialized: compactSerialized,
      claimDisplayNames: claimDisplayNames,
      claimsCount: claimsCount,
      issuedAt: issuedAt,
      type: type,
      displayData: displayData?.toDomain()
    )
  }
}

extension CurrentSchema.IssuerDisplay {
  init(_ issuer: CredentialInterfaces.IssuerDisplay) {
    self.init(name: issuer.name, info: issuer.info, imageUrl: issuer.imageUrl)
  }

  func toDomain() -> CredentialInterfaces.IssuerDisplay {
    CredentialInterfaces.IssuerDisplay(name: name, info: info, imageUrl: imageUrl)
  }
}

extension CurrentSchema.CredentialDisplayData {
  init(_ displayData: CredentialInterfaces.CredentialDisplayData) {
    self.init(name: displayData.name)
  }

  func toDomain() -> CredentialInterfaces.CredentialDisplayData {
    CredentialInterfaces.CredentialDisplayData(name: name)
  }
}

extension CurrentSchema.HsmServerParameters {
  init(_ parameters: HsmServerParameters) {
    self.init(
      serverJwsPublicKey: SchemaV3.HsmServerJwk(
        kty: parameters.serverJwsPublicKey.kty,
        crv: parameters.serverJwsPublicKey.crv,
        x: parameters.serverJwsPublicKey.x,
        y: parameters.serverJwsPublicKey.y,
        kid: parameters.serverJwsPublicKey.kid
      ),
      opaqueContext: parameters.opaqueContext,
      opaqueServerIdentifier: parameters.opaqueServerIdentifier
    )
  }

  func toDomain() -> HsmServerParameters {
    HsmServerParameters(
      serverJwsPublicKey: HsmServerParameters.Jwk(
        kty: serverJwsPublicKey.kty,
        crv: serverJwsPublicKey.crv,
        x: serverJwsPublicKey.x,
        y: serverJwsPublicKey.y,
        kid: serverJwsPublicKey.kid
      ),
      opaqueContext: opaqueContext,
      opaqueServerIdentifier: opaqueServerIdentifier
    )
  }
}

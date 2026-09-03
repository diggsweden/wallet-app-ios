// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import OpenID4VCI
import OpenId4VCInterface

extension CredentialOffer {
  func sdJwtVcConfiguration() throws -> (
    id: CredentialConfigurationIdentifier,
    configuration: SdJwtVcFormat.CredentialConfiguration
  ) {
    guard
      let configId = credentialConfigurationIdentifiers.first,
      let supportedCredential = credentialIssuerMetadata.credentialsSupported[configId],
      case let .sdJwtVc(credentialConfig) = supportedCredential
    else {
      throw IssuanceError.credentialNotSupported
    }

    return (configId, credentialConfig)
  }

  var claimDisplayNames: [String: String] {
    credentialConfigurationIdentifiers
      .compactMap { id in
        credentialIssuerMetadata.credentialsSupported[id]
      }
      .flatMap { supportedCredential in
        switch supportedCredential {
          case .sdJwtVc(let config):
            return config.credentialMetadata?.claims ?? []

          case .msoMdoc(let config):
            return config.credentialMetadata?.claims ?? []

          default:
            return []
        }
      }
      .reduce(into: [String: String]()) { result, claim in
        let claimPath = claim.path.value
          .map(\.description)
          .joined(separator: ".")

        if let name = claim.display?.first?.name {
          result[claimPath] = name
        }
      }
  }
}

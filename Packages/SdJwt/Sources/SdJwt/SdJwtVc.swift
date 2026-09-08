// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import CredentialInterfaces
import Foundation
import eudi_lib_sdjwt_swift

public struct DisclosedSdJwt: Sendable {
  public let compactSerialized: String
  public let claims: [ClaimUiModel]

  public init(compactSerialized: String, claims: [ClaimUiModel]) {
    self.compactSerialized = compactSerialized
    self.claims = claims
  }
}

public enum SdJwtVc {
  public static func claimUiModels(
    compactSerialized: String,
    displayNames: [String: String],
  ) throws -> [ClaimUiModel] {
    try CompactParser()
      .getSignedSdJwt(serialisedString: compactSerialized)
      .toClaimUiModels(displayNames: displayNames)
  }

  public static func disclose(
    compactSerialized: String,
    matching paths: Set<CredentialInterfaces.ClaimPath>,
    displayNames: [String: String],
  ) throws -> DisclosedSdJwt? {
    let sdJwt = try CompactParser().getSignedSdJwt(serialisedString: compactSerialized)

    guard let disclosed = try sdJwt.present(query: Set(paths.map(\.libClaimPath))) else {
      return nil
    }

    return DisclosedSdJwt(
      compactSerialized: disclosed.serialisation,
      claims: try disclosed.toClaimUiModels(displayNames: displayNames),
    )
  }
}

extension CredentialInterfaces.ClaimPath {
  var libClaimPath: eudi_lib_sdjwt_swift.ClaimPath {
    eudi_lib_sdjwt_swift.ClaimPath(
      elements.map { element in
        switch element {
          case .claim(let name): .claim(name: name)
          case .arrayElement(let index): .arrayElement(index: index)
          case .allArrayElements: .allArrayElements
        }
      }
    )
  }
}

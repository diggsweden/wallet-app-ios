// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import CredentialInterfaces
import CredentialInterfacesTestSupport
import Testing
import eudi_lib_sdjwt_swift

@testable import SdJwtClaims

struct ClaimUiModelRenderingTests {
  private func claims(displayNames: [String: String] = [:]) throws -> [ClaimUiModel] {
    try CompactParser()
      .getSignedSdJwt(serialisedString: SampleCredential.compactSdJwt)
      .toClaimUiModels(displayNames: displayNames)
  }

  @Test func `every disclosure becomes a claim in id order and reserved claims are skipped`()
    throws
  {
    #expect(
      try claims().map(\.id) == [
        "address", "birthdate", "family_name", "given_name", "nationalities",
      ]
    )
  }

  @Test func `a claim is named from the display names when one is given`() throws {
    let claims = try claims(displayNames: ["given_name": "Förnamn"])

    #expect(claims.first { $0.id == "given_name" }?.displayName == "Förnamn")
  }

  @Test func `a claim without a display name falls back to its title-cased id`() throws {
    let claims = try claims()

    #expect(claims.first { $0.id == "family_name" }?.displayName == "Family Name")
    #expect(claims.first { $0.id == "birthdate" }?.displayName == "Birthdate")
  }
}

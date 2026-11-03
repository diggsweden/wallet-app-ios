// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import CredentialInterfaces
import CredentialInterfacesTestSupport
import Foundation
import Jose
import OpenID4VP
import OpenId4VCInterface
import WalletMacros

@testable import Presentation

/// Builds presentation requests, both as the resolver produces them and as the
/// DCQL JSON it receives.
enum Fixtures {
  static let responseUrl = #URL("https://verifier.example/response")
  static let verifierUiModel = VerifierUiModel(
    name: "Example Verifier",
    country: "SE",
    descriptions: [:],
    purpose: [:],
  )

  static func query(
    id: String,
    format: String = "dc+sd-jwt",
    claims: [String] = ["given_name"],
    required: Bool = true,
    vctValues: Set<String> = [SampleCredential.pidType],
  ) -> Presentation.CredentialQuery {
    CredentialQuery(
      id: id,
      format: format,
      claimPaths: Set(claims.map { CredentialInterfaces.ClaimPath([.claim(name: $0)]) }),
      required: required,
      vctValues: Set(vctValues),
    )
  }

  static func request(
    _ queries: [Presentation.CredentialQuery],
    state: String? = "state-1",
    encryption: CryptoSpec? = nil,
  ) -> PresentationRequestData {
    PresentationRequestData(
      credentialQueries: queries,
      responseUrl: responseUrl,
      clientId: "verifier-1",
      nonce: "nonce-1",
      state: state,
      encryption: encryption,
      registrationCertificates: [],
      legalName: nil,
    )
  }

  /// Decodes a DCQL document the way the OpenID4VP library does before the
  /// resolver maps it.
  static func dcql(credentials: String, credentialSets: String? = nil) throws -> DCQL {
    let sets = credentialSets.map { #", "credential_sets": \#($0)"# } ?? ""
    let json = #"{"credentials": \#(credentials)\#(sets)}"#
    return try JSONDecoder().decode(DCQL.self, from: Data(json.utf8))
  }

  /// One DCQL credential query for the PID, as JSON. `nil` claims omits the member.
  static func pidCredential(
    id: String = "pid",
    claims: String? = #"[{"path": ["given_name"]}]"#,
  ) -> String {
    let claimsMember = claims.map { #", "claims": \#($0)"# } ?? ""
    return #"{"id": "\#(id)", "format": "dc+sd-jwt", "#
      + #""meta": {"vct_values": ["\#(SampleCredential.pidType)"]}\#(claimsMember)}"#
  }
}

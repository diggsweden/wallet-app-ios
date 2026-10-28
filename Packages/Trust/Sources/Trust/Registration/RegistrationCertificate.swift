// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import CredentialInterfaces
import Foundation

// MARK: - Welcome
public struct RegistrationCertificate: Codable {
  let name: String
  let sub: String
  let country: String
  let iat: Int
  let exp: Int
  let registryURI: String
  let srvDescription: [Display]
  let entitlements: [String]
  let purpose: [Display]
  let credentials: [Credential]
  let serviceIdentifier: String
  let intendedUseID: String
  let privacyPolicy: String
  let infoURI: String
  let supportURI: String
  let supervisoryAuthority: SupervisoryAuthority
  let policyID: [String]
  let certificatePolicy: String
  let status: Status

  enum CodingKeys: String, CodingKey {
    case name = "name"
    case sub = "sub"
    case country = "country"
    case iat = "iat"
    case exp = "exp"
    case registryURI = "registry_uri"
    case srvDescription = "srv_description"
    case entitlements = "entitlements"
    case purpose = "purpose"
    case credentials = "credentials"
    case serviceIdentifier = "service_identifier"
    case intendedUseID = "intended_use_id"
    case privacyPolicy = "privacy_policy"
    case infoURI = "info_uri"
    case supportURI = "support_uri"
    case supervisoryAuthority = "supervisory_authority"
    case policyID = "policy_id"
    case certificatePolicy = "certificate_policy"
    case status = "status"
  }
}

// MARK: - Credential
struct Credential: Codable {
  let format: String
  let meta: Meta
  let claim: [Claim]
}

// MARK: - Claim
struct Claim: Codable {
  let path: ClaimPath
}

// MARK: - Meta
struct Meta: Codable {
  let vctValues: [String]

  enum CodingKeys: String, CodingKey {
    case vctValues = "vct_values"
  }
}

// MARK: - Purpose
struct Display: Codable {
  let lang: String
  let value: String
}

// MARK: - Status
struct Status: Codable {
  let statusList: StatusList

  enum CodingKeys: String, CodingKey {
    case statusList = "status_list"
  }
}

// MARK: - StatusList
struct StatusList: Codable {
  let uri: String
  let idx: Int
}

// MARK: - SupervisoryAuthority
struct SupervisoryAuthority: Codable {
  let name: String
  let country: String
  let email: String
}

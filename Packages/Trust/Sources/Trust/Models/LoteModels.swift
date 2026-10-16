import Foundation

// MARK: - Trust
struct Trust: Codable {
  let loTE: LoTE

  enum CodingKeys: String, CodingKey {
    case loTE = "LoTE"
  }
}

// MARK: - LoTE
struct LoTE: Codable {
  let listAndSchemeInformation: ListAndSchemeInformation
  let trustedEntitiesList: [TrustedEntitiesList]

  enum CodingKeys: String, CodingKey {
    case listAndSchemeInformation = "ListAndSchemeInformation"
    case trustedEntitiesList = "TrustedEntitiesList"
  }
}

// MARK: - ListAndSchemeInformation
struct ListAndSchemeInformation: Codable {
  let loTEVersionIdentifier: Int
  let loTESequenceNumber: Int
  let loTEType: String
  let schemeOperatorName: [Name]
  let schemeName: [Name]
  let schemeTerritory: String
  let listIssueDateTime: Date
  let nextUpdate: Date

  enum CodingKeys: String, CodingKey {
    case loTEVersionIdentifier = "LoTEVersionIdentifier"
    case loTESequenceNumber = "LoTESequenceNumber"
    case loTEType = "LoTEType"
    case schemeOperatorName = "SchemeOperatorName"
    case schemeName = "SchemeName"
    case schemeTerritory = "SchemeTerritory"
    case listIssueDateTime = "ListIssueDateTime"
    case nextUpdate = "NextUpdate"
  }
}

// MARK: - Name
struct Name: Codable {
  let lang: String
  let value: String
}

// MARK: - TrustedEntitiesList
struct TrustedEntitiesList: Codable {
  let trustedEntityInformation: TrustedEntityInformation
  let trustedEntityServices: [TrustedEntityService]

  enum CodingKeys: String, CodingKey {
    case trustedEntityInformation = "TrustedEntityInformation"
    case trustedEntityServices = "TrustedEntityServices"
  }
}

// MARK: - TrustedEntityInformation
struct TrustedEntityInformation: Codable {
  let teName: [Name]
  let teAddress: TEAddress
  let teInformationURI: [Te]

  enum CodingKeys: String, CodingKey {
    case teName = "TEName"
    case teAddress = "TEAddress"
    case teInformationURI = "TEInformationURI"
  }
}

// MARK: - TEAddress
struct TEAddress: Codable {
  let tePostalAddress: [TEPostalAddress]
  let teElectronicAddress: [Te]

  enum CodingKeys: String, CodingKey {
    case tePostalAddress = "TEPostalAddress"
    case teElectronicAddress = "TEElectronicAddress"
  }
}

// MARK: - Te
struct Te: Codable {
  let lang: String
  let uriValue: String
}

// MARK: - TEPostalAddress
struct TEPostalAddress: Codable {
  let lang: String
  let streetAddress: String
  let country: String

  enum CodingKeys: String, CodingKey {
    case lang = "lang"
    case streetAddress = "StreetAddress"
    case country = "Country"
  }
}

// MARK: - TrustedEntityService
struct TrustedEntityService: Codable {
  let serviceInformation: ServiceInformation

  enum CodingKeys: String, CodingKey {
    case serviceInformation = "ServiceInformation"
  }
}

// MARK: - ServiceInformation
struct ServiceInformation: Codable {
  let serviceName: [Name]
  let serviceDigitalIdentity: ServiceDigitalIdentity
  let serviceTypeIdentifier: String
  let serviceStatus: String?
  let statusStartingTime: Date?

  enum CodingKeys: String, CodingKey {
    case serviceName = "ServiceName"
    case serviceDigitalIdentity = "ServiceDigitalIdentity"
    case serviceTypeIdentifier = "ServiceTypeIdentifier"
    case serviceStatus = "ServiceStatus"
    case statusStartingTime = "StatusStartingTime"
  }
}

// MARK: - ServiceDigitalIdentity
struct ServiceDigitalIdentity: Codable {
  let x509Certificates: [X509Certificate]

  enum CodingKeys: String, CodingKey {
    case x509Certificates = "X509Certificates"
  }
}

// MARK: - X509Certificate
struct X509Certificate: Codable {
  let val: String
}

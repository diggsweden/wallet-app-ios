// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import Foundation
import Jose

@testable import Trust

enum Fixtures {
  struct Service {
    let type: String
    let certificates: [String]
  }

  static let rootCertificate = base64(
    """
    MIIBmjCCAUGgAwIBAgIUQ4lx3yVbRV9+AluDYDFKEpHVx6swCgYIKoZIzj0EAwIwGjEYMBYGA1UE
    AwwPVHJ1c3QgVGVzdCBSb290MCAXDTI2MTAyMDEyNTYwMloYDzIxMjYwOTI2MTI1NjAyWjAaMRgw
    FgYDVQQDDA9UcnVzdCBUZXN0IFJvb3QwWTATBgcqhkjOPQIBBggqhkjOPQMBBwNCAARKLIInVXPH
    AhAs33KpE4a6TEbQlfulvBrMyuvb2p85yU6rJIm0xJXoK743L+P9vvZwh/CwO76AfngfPtiJBbXh
    o2MwYTAdBgNVHQ4EFgQUxKk8CzTUYuWq6By9UjZJj0tMZ7QwHwYDVR0jBBgwFoAUxKk8CzTUYuWq
    6By9UjZJj0tMZ7QwDwYDVR0TAQH/BAUwAwEB/zAOBgNVHQ8BAf8EBAMCAQYwCgYIKoZIzj0EAwID
    RwAwRAIgemOADQG+2NcHITXwy0XlqHwO4Izhrr78kTUyWhIrAoMCIBohYzoy3BIjfA5nRPc/Ftvm
    7OLaFYBDPhj75rr3GKS6
    """
  )

  static let otherCertificate = base64(
    """
    MIIBpjCCAU2gAwIBAgIUO8fUhlcfZrHi0inI2dd4H1VvXqMwCgYIKoZIzj0EAwIwIDEeMBwGA1UE
    AwwVVHJ1c3QgVGVzdCBPdGhlciBSb290MCAXDTI2MTAyMDEyNTYwMloYDzIxMjYwOTI2MTI1NjAy
    WjAgMR4wHAYDVQQDDBVUcnVzdCBUZXN0IE90aGVyIFJvb3QwWTATBgcqhkjOPQIBBggqhkjOPQMB
    BwNCAATOBUHpYEh1nb8raQEPgg0LNY7cM76S2LfRRN9CG6k4UJCBlqKOatVPh/8w9SyhfD69uKZI
    kkcRV4JlmGTcq+Dyo2MwYTAdBgNVHQ4EFgQUQ/K6Qej33EJMJ3P9WNm7VVPWmm8wHwYDVR0jBBgw
    FoAUQ/K6Qej33EJMJ3P9WNm7VVPWmm8wDwYDVR0TAQH/BAUwAwEB/zAOBgNVHQ8BAf8EBAMCAQYw
    CgYIKoZIzj0EAwIDRwAwRAIgG437N5/uc3Ey20nm1OafUWgSH4WYN+teiYknk+MpwZ4CIAYNXPIi
    SZqbKN5uD43jURhtNS7W2okRfDTNQbi/6SI/
    """
  )

  static let leafCertificate = base64(
    """
    MIIBvjCCAWWgAwIBAgIUbpkqP65WpmGbcp4fNtv6YDdtmGYwCgYIKoZIzj0EAwIwGjEYMBYGA1UE
    AwwPVHJ1c3QgVGVzdCBSb290MCAXDTI2MTAyMDEyNTYwMloYDzIxMjYwOTI2MTI1NjAyWjAfMR0w
    GwYDVQQDDBR2ZXJpZmllci5leGFtcGxlLmNvbTBZMBMGByqGSM49AgEGCCqGSM49AwEHA0IABFbB
    5NJ8WqvJ8souMg2rOL8FxSVfX11xsdweEnKHx3hyoBL8Ll8CVHph9JExHMBUiFBuvmqNfUcZmuhN
    IJ2DNhajgYEwfzAMBgNVHRMBAf8EAjAAMA4GA1UdDwEB/wQEAwIHgDAfBgNVHREEGDAWghR2ZXJp
    Zmllci5leGFtcGxlLmNvbTAdBgNVHQ4EFgQU23r+KjYbq8xiR9zidmYFNWbZiJswHwYDVR0jBBgw
    FoAUxKk8CzTUYuWq6By9UjZJj0tMZ7QwCgYIKoZIzj0EAwIDRwAwRAIgTw85n1d/XfJ4EyvOpPAp
    H8fW8WTFdudfZH2jzeSz/NYCIGq+7Gqi5G1VxIiYGQtjaS0h136xhJ0Mc0NKm1kAfHi4
    """
  )

  static func certificate(_ base64: String) throws -> SecCertificate {
    guard let data = Data(base64Encoded: base64),
      let certificate = SecCertificateCreateWithData(nil, data as CFData)
    else {
      throw FixtureError.invalidCertificate
    }
    return certificate
  }

  static func der(_ certificate: SecCertificate) -> Data {
    SecCertificateCopyData(certificate) as Data
  }

  static func der(of base64: String) throws -> Data {
    der(try certificate(base64))
  }

  static func loteJson(_ services: [Service]) throws -> Data {
    let list: [String: Any] = [
      "LoTE": [
        "ListAndSchemeInformation": [
          "LoTEVersionIdentifier": 1,
          "LoTESequenceNumber": 1,
          "LoTEType": "http://uri.etsi.org/19602/LoTEType/EUWRPACProvidersList",
          "SchemeOperatorName": [name("Operator")],
          "SchemeName": [name("Scheme")],
          "SchemeTerritory": "SE",
          "ListIssueDateTime": "2026-01-01T00:00:00Z",
          "NextUpdate": "2026-07-01T00:00:00Z",
        ],
        "TrustedEntitiesList": [
          [
            "TrustedEntityInformation": [
              "TEName": [name("Provider")],
              "TEAddress": [
                "TEPostalAddress": [
                  ["lang": "en", "StreetAddress": "Street 1", "Country": "SE"]
                ],
                "TEElectronicAddress": [uri("mailto:provider@example.com")],
              ],
              "TEInformationURI": [uri("https://provider.example.com")],
            ],
            "TrustedEntityServices": services.map(service),
          ]
        ],
      ]
    ]
    return try JSONSerialization.data(withJSONObject: list)
  }

  static func loteJwt(_ services: [Service]) throws -> Data {
    let header = Data(#"{"alg":"ES256","typ":"JWT"}"#.utf8).base64UrlEncodedString()
    let payload = try loteJson(services).base64UrlEncodedString()
    let signature = Data("signature".utf8).base64UrlEncodedString()
    return Data("\(header).\(payload).\(signature)".utf8)
  }

  private static func service(_ service: Service) -> [String: Any] {
    [
      "ServiceInformation": [
        "ServiceName": [name("Service")],
        "ServiceDigitalIdentity": [
          "X509Certificates": service.certificates.map { ["val": $0] }
        ],
        "ServiceTypeIdentifier": service.type,
      ]
    ]
  }

  private static func name(_ value: String) -> [String: String] {
    ["lang": "en", "value": value]
  }

  private static func uri(_ value: String) -> [String: String] {
    ["lang": "en", "uriValue": value]
  }

  private static func base64(_ wrapped: String) -> String {
    wrapped.replacingOccurrences(of: "\n", with: "")
  }
}

enum FixtureError: Error {
  case invalidCertificate
}

// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import Foundation
import WalletGatewayInterface

protocol TrustStoreInterface {
}

enum ServiceType: String {
  case wrpacIssuance = "http://uri.etsi.org/19602/SvcType/WRPAC/Issuance"
  case wrpacRevocation = "http://uri.etsi.org/19602/SvcType/WRPAC/Revocation"
  case wrprcIssuance = "http://uri.etsi.org/19602/SvcType/WRPRC/Issuance"
  case wrprcRevocation = "http://uri.etsi.org/19602/SvcType/WRPRC/Revocation"
}

public actor TrustStore: TrustStoreInterface {
  private let walletGatewayApi: GatewayApi
  private let trustNetworkClient: TrustNetworkClient
  public private(set) var serviceTrustAnchors: [String: [SecCertificate]] = [:]

  public init(
    walletGatewayApi: GatewayApi,
    urlSession: URLSession = URLSession.shared,
  ) {
    self.walletGatewayApi = walletGatewayApi
    self.trustNetworkClient = TrustNetworkClient(urlSession: urlSession)
  }

  public func create() async throws {
    try await fetchTrustedLists()
  }

  private func fetchTrustedLists() async throws {
    let providerUrls = try await walletGatewayApi.fetchTrustedListProviders()

    let trustedLists = await withTaskGroup(of: Trust?.self) { group in
      for url in providerUrls {
        group.addTask {
          do {
            let response = try await self.trustNetworkClient.fetch(from: url)
            return try LoteParser.parse(response)
          } catch {
            print("Could not get trusted list: \(url) with error: \(error)")
            return nil
          }
        }
      }

      var lists: [Trust] = []
      for await trust in group {
        if let trust { lists.append(trust) }
      }

      return lists
    }

    let trustedEntitiesList = trustedLists.map(\.loTE)
      .flatMap(\.trustedEntitiesList)

    convertCertificates(trustedEntitiesList)
  }

  private func convertCertificates(_ trustedEntitiesList: [TrustedEntitiesList]) {
    let trustedEntityServices = trustedEntitiesList.flatMap(\.trustedEntityServices)

    serviceTrustAnchors = trustedEntityServices.reduce(into: [String: [SecCertificate]]()) {
      dict,
      service in
      dict[service.serviceInformation.serviceTypeIdentifier] = service.serviceInformation
        .serviceDigitalIdentity.x509Certificates.compactMap(\.toSecCertificate)
    }
  }
}

fileprivate extension X509Certificate {
  var toSecCertificate: SecCertificate? {
    guard let data = Data(base64UrlEncoded: self.val) else {
      return nil
    }
    return SecCertificateCreateWithData(nil, data as CFData)
  }
}

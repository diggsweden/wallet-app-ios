// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import Foundation
import WalletGatewayInterface

public actor TrustStore: TrustStoreInterface {
  private typealias TrustAnchorsByServiceType = [String: [SecCertificate]]

  private let walletGatewayApi: GatewayApi
  private let trustListFetcher: any TrustListFetching
  private var trustAnchorsTask: Task<TrustAnchorsByServiceType, Error>?

  public init(
    walletGatewayApi: GatewayApi,
    urlSession: URLSession = URLSession.shared,
  ) {
    self.init(
      walletGatewayApi: walletGatewayApi,
      trustListFetcher: TrustNetworkClient(urlSession: urlSession),
    )
  }

  init(
    walletGatewayApi: GatewayApi,
    trustListFetcher: any TrustListFetching,
  ) {
    self.walletGatewayApi = walletGatewayApi
    self.trustListFetcher = trustListFetcher

    Task { _ = try? await loadTrustAnchors() }
  }

  public func getTrustAnchors(for serviceType: String) async throws -> [SecCertificate] {
    let trustAnchorsByServiceType = try await loadTrustAnchors()

    guard let trustAnchors = trustAnchorsByServiceType[serviceType] else {
      throw TrustStoreError.noTrustAnchors(serviceType: serviceType)
    }

    return trustAnchors
  }

  private func loadTrustAnchors() async throws -> TrustAnchorsByServiceType {
    if let trustAnchorsTask {
      return try await trustAnchorsTask.value
    }

    let task = Task {
      do {
        return try await fetchTrustAnchors()
      } catch {
        trustAnchorsTask = nil
        throw error
      }
    }
    trustAnchorsTask = task

    return try await task.value
  }

  private func fetchTrustAnchors() async throws -> TrustAnchorsByServiceType {
    let providerUrls = try await walletGatewayApi.fetchTrustedListProviders()

    let lotes = await withTaskGroup(of: LoTE?.self) { group in
      for url in providerUrls {
        group.addTask {
          do {
            let response = try await self.trustListFetcher.fetch(from: url)
            return try LoteParser.parse(response).loTE
          } catch {
            print("Could not get trusted list: \(url) with error: \(error)")
            return nil
          }
        }
      }

      var lotes: [LoTE] = []
      for await case let lote? in group {
        lotes.append(lote)
      }

      return lotes
    }

    let services =
      lotes
      .flatMap(\.trustedEntitiesList)
      .flatMap(\.trustedEntityServices)

    let trustAnchorsByServiceType = groupTrustAnchors(from: services)

    if trustAnchorsByServiceType.isEmpty {
      throw TrustStoreError.noTrustAnchorsLoaded
    }

    return trustAnchorsByServiceType
  }

  private func groupTrustAnchors(
    from services: [TrustedEntityService]
  ) -> TrustAnchorsByServiceType {
    services.reduce(into: [:]) { dict, service in
      let serviceType = service.serviceInformation.serviceTypeIdentifier
      let trustAnchors = service.serviceInformation.serviceDigitalIdentity.x509Certificates
        .compactMap(\.secCertificate)

      dict[serviceType, default: []].append(contentsOf: trustAnchors)
    }
  }
}

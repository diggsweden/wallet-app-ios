// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import Foundation

struct TrustNetworkClient: TrustListFetching {
  private let urlSession: URLSession

  init(urlSession: URLSession = URLSession.shared) {
    self.urlSession = urlSession
  }

  func fetch(from url: URL) async throws -> LoteResponse {
    let (data, response) = try await urlSession.data(from: url)

    guard let httpResponse = response as? HTTPURLResponse else {
      throw TrustListError.invalidResponse(url: url)
    }

    guard 200 ... 299 ~= httpResponse.statusCode else {
      throw TrustListError.http(response: httpResponse, body: data)
    }

    guard
      let mimeType = httpResponse.mimeType,
      let loteContentType = LoteContentType(rawValue: mimeType)
    else {
      throw TrustListError.unsupportedContentType(httpResponse.mimeType)
    }

    return LoteResponse(data: data, type: loteContentType)
  }
}

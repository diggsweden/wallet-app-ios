// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import Foundation

@testable import Trust

actor FakeTrustListFetcher: TrustListFetching {
  struct Failure: Error {}

  private let responses: [URL: LoteResponse]
  private let failingCalls: Int
  private var fetchCount = 0

  init(responses: [URL: LoteResponse], failingCalls: Int = 0) {
    self.responses = responses
    self.failingCalls = failingCalls
  }

  func fetch(from url: URL) throws -> LoteResponse {
    fetchCount += 1

    guard fetchCount > failingCalls, let response = responses[url] else {
      throw Failure()
    }

    return response
  }
}

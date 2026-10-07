// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import Foundation

@testable import QRScanner

@MainActor
final class FakeCodeScanner: CodeScanner {
  enum Script: Sendable {
    case events([ScanEvent])
    case throwsOnStart
  }

  struct StartFailure: Error {}

  private var scripts: [Script]
  private var continuation: AsyncStream<ScanEvent>.Continuation?

  private(set) var startCount = 0
  private(set) var stopCount = 0

  var onStart: () -> Void = {}

  init(scripts: [Script] = []) {
    self.scripts = scripts
  }

  func start() throws -> AsyncStream<ScanEvent> {
    startCount += 1
    onStart()

    let script = scripts.isEmpty ? .events([]) : scripts.removeFirst()
    guard case let .events(events) = script else { throw StartFailure() }

    let (stream, continuation) = AsyncStream.makeStream(of: ScanEvent.self)
    self.continuation = continuation
    for event in events { continuation.yield(event) }
    return stream
  }

  func stop() {
    stopCount += 1
    continuation?.finish()
    continuation = nil
  }
}

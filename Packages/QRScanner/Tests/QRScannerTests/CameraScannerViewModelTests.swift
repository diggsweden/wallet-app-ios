// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import Foundation
import Testing

@testable import QRScanner

@MainActor
struct CameraScannerViewModelTests {
  private static let supportedSchemes: Set<String> = ["scheme-a", "scheme-b"]

  private func makeViewModel(
    _ scanner: FakeCodeScanner,
    onSuccess: @escaping (URL) -> Void = { _ in },
  ) -> CameraScannerViewModel {
    CameraScannerViewModel(
      scanner: scanner,
      supportedSchemes: Self.supportedSchemes,
      onSuccess: onSuccess,
    )
  }

  @Test(arguments: ["scheme-a://open", "SCHEME-A://open", "scheme-b://?request_uri=x"])
  func `reports a code with a supported scheme`(_ payload: String) async {
    let scanner = FakeCodeScanner(scripts: [.events([.scanned(payload)])])
    var urls: [URL] = []
    let viewModel = makeViewModel(scanner) { urls.append($0) }

    await viewModel.scan()

    #expect(urls == [URL(string: payload)!])
    #expect(viewModel.state.isScanned)
    #expect(scanner.startCount == 1)
    #expect(scanner.stopCount == 1)
  }

  @Test(arguments: ["https://example.com", "other-scheme://open", "not a url", ""])
  func `rejects a code with an unsupported scheme`(_ payload: String) async {
    let scanner = FakeCodeScanner(scripts: [.events([.scanned(payload)])])
    var urls: [URL] = []
    let viewModel = makeViewModel(scanner) { urls.append($0) }

    await viewModel.scan()

    #expect(urls.isEmpty)
    #expect(viewModel.scanError == .unsupportedCode)
    #expect(scanner.stopCount == 1)
  }

  @Test
  func `the first scanned code decides the outcome until retry`() async {
    let scanner = FakeCodeScanner(scripts: [
      .events([.scanned("other-scheme://first"), .scanned("scheme-a://second")])
    ])
    var urls: [URL] = []
    let viewModel = makeViewModel(scanner) { urls.append($0) }

    await viewModel.scan()

    #expect(urls.isEmpty)
    #expect(viewModel.scanError == .unsupportedCode)
  }

  @Test
  func `becomes unavailable when the scanner reports it`() async {
    let scanner = FakeCodeScanner(scripts: [.events([.unavailable])])
    var urls: [URL] = []
    let viewModel = makeViewModel(scanner) { urls.append($0) }

    await viewModel.scan()

    #expect(urls.isEmpty)
    #expect(viewModel.state.isUnavailable)
    #expect(scanner.stopCount == 1)
  }

  @Test
  func `becomes unavailable when the scanner fails to start`() async {
    let scanner = FakeCodeScanner(scripts: [.throwsOnStart])
    var urls: [URL] = []
    let viewModel = makeViewModel(scanner) { urls.append($0) }

    await viewModel.scan()

    #expect(urls.isEmpty)
    #expect(viewModel.state.isUnavailable)
    #expect(scanner.stopCount == 1, "the scanner is stopped even when starting it fails")
  }

  @Test
  func `cancelling a scan keeps the scanning state`() async {
    let scanner = FakeCodeScanner()
    let viewModel = makeViewModel(scanner)
    let (started, startedContinuation) = AsyncStream.makeStream(of: Void.self)
    scanner.onStart = { startedContinuation.yield() }

    let scan = Task { await viewModel.scan() }
    for await _ in started { break }
    scan.cancel()
    await scan.value

    #expect(viewModel.state.isScanning, "pausing must not leave the scanning state")
    #expect(scanner.stopCount == 1)
  }

  @Test
  func `reports only the first supported code`() async {
    let scanner = FakeCodeScanner(scripts: [
      .events([.scanned("scheme-a://first"), .scanned("scheme-b://second")])
    ])
    var urls: [URL] = []
    let viewModel = makeViewModel(scanner) { urls.append($0) }

    await viewModel.scan()

    #expect(urls == [URL(string: "scheme-a://first")!])
    #expect(viewModel.state.isScanned)
    #expect(scanner.startCount == 1)
    #expect(scanner.stopCount == 1)
  }

  @Test
  func `retry resumes scanning after an unsupported code`() async {
    let scanner = FakeCodeScanner(scripts: [.events([.scanned("other-scheme://open")])])
    let viewModel = makeViewModel(scanner)
    await viewModel.scan()
    #expect(viewModel.scanError == .unsupportedCode)

    viewModel.retry()

    #expect(viewModel.state.isScanning)
    #expect(viewModel.scanError == nil)
  }

  @Test(arguments: [
    FakeCodeScanner.Script.events([.unavailable]),
    .throwsOnStart,
  ])
  func `retry is ignored when unavailable`(_ script: FakeCodeScanner.Script) async {
    let viewModel = makeViewModel(FakeCodeScanner(scripts: [script]))
    await viewModel.scan()

    viewModel.retry()

    #expect(viewModel.state.isUnavailable)
  }

  @Test
  func `retry is ignored after a successful scan`() async {
    let scanner = FakeCodeScanner(scripts: [.events([.scanned("scheme-a://open")])])
    let viewModel = makeViewModel(scanner)
    await viewModel.scan()

    viewModel.retry()

    #expect(viewModel.state.isScanned)
  }

  @Test
  func `a rejected code can be followed by a supported one`() async {
    let scanner = FakeCodeScanner(scripts: [
      .events([.scanned("other-scheme://open")]),
      .events([.scanned("scheme-a://open")]),
    ])
    var urls: [URL] = []
    let viewModel = makeViewModel(scanner) { urls.append($0) }

    await viewModel.scan()
    #expect(urls.isEmpty)
    viewModel.retry()
    await viewModel.scan()

    #expect(urls == [URL(string: "scheme-a://open")!])
    #expect(viewModel.state.isScanned)
    #expect(scanner.startCount == 2)
    #expect(scanner.stopCount == 2)
  }

  @Test(arguments: ["scheme-a://open", "other-scheme://open"])
  func `ignores codes while paused`(_ payload: String) async {
    let scanner = FakeCodeScanner(scripts: [.events([.scanned(payload)])])
    var urls: [URL] = []
    let viewModel = makeViewModel(scanner) { urls.append($0) }
    viewModel.isPaused = true

    await viewModel.scan()

    #expect(urls.isEmpty)
    #expect(viewModel.state.isScanning)
    #expect(scanner.stopCount == 1)
  }

  @Test
  func `resumes scanning after a pause`() async {
    let scanner = FakeCodeScanner(scripts: [
      .events([.scanned("scheme-a://paused")]),
      .events([.scanned("scheme-b://resumed")]),
    ])
    var urls: [URL] = []
    let viewModel = makeViewModel(scanner) { urls.append($0) }
    viewModel.isPaused = true
    await viewModel.scan()

    viewModel.isPaused = false
    await viewModel.scan()

    #expect(urls == [URL(string: "scheme-b://resumed")!])
    #expect(viewModel.state.isScanned)
  }
}

private extension CameraScannerViewModel.State {
  var isScanning: Bool {
    if case .scanning = self { true } else { false }
  }

  var isScanned: Bool {
    if case .scanned = self { true } else { false }
  }

  var isUnavailable: Bool {
    if case .unavailable = self { true } else { false }
  }
}

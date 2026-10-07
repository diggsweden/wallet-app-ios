// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import Foundation
import Testing

@testable import QRScanner

@MainActor
struct CameraScannerViewModelTests {
  private static let supportedSchemes: Set<String> = ["scheme-a", "scheme-b"]

  private func makeViewModel(_ scanner: FakeCodeScanner) -> CameraScannerViewModel {
    CameraScannerViewModel(scanner: scanner, supportedSchemes: Self.supportedSchemes)
  }

  @Test(arguments: ["scheme-a://open", "SCHEME-A://open", "scheme-b://?request_uri=x"])
  func `opens a code with a supported scheme`(_ payload: String) async {
    let scanner = FakeCodeScanner(scripts: [.events([.scanned(payload)])])
    let viewModel = makeViewModel(scanner)

    let url = await viewModel.scan()

    #expect(url == URL(string: payload))
    #expect(viewModel.state.isOpeningURL)
    #expect(scanner.startCount == 1)
    #expect(scanner.stopCount == 1)
  }

  @Test(arguments: ["https://example.com", "other-scheme://open", "not a url", ""])
  func `rejects a code with an unsupported scheme`(_ payload: String) async {
    let scanner = FakeCodeScanner(scripts: [.events([.scanned(payload)])])
    let viewModel = makeViewModel(scanner)

    let url = await viewModel.scan()

    #expect(url == nil)
    #expect(viewModel.state.failure == .unsupportedCode)
    #expect(scanner.stopCount == 1)
  }

  @Test
  func `the first scanned code decides the outcome`() async {
    let scanner = FakeCodeScanner(scripts: [
      .events([.scanned("other-scheme://first"), .scanned("scheme-a://second")])
    ])
    let viewModel = makeViewModel(scanner)

    let url = await viewModel.scan()

    #expect(url == nil)
    #expect(viewModel.state.failure == .unsupportedCode)
  }

  @Test
  func `becomes unavailable when the scanner reports it`() async {
    let scanner = FakeCodeScanner(scripts: [.events([.unavailable])])
    let viewModel = makeViewModel(scanner)

    let url = await viewModel.scan()

    #expect(url == nil)
    #expect(viewModel.state.isUnavailable)
    #expect(scanner.stopCount == 1)
  }

  @Test
  func `becomes unavailable when the scanner fails to start`() async {
    let scanner = FakeCodeScanner(scripts: [.throwsOnStart])
    let viewModel = makeViewModel(scanner)

    let url = await viewModel.scan()

    #expect(url == nil)
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

    #expect(await scan.value == nil)
    #expect(viewModel.state.isScanning, "pausing must not leave the scanning state")
    #expect(scanner.stopCount == 1)
  }

  @Test
  func `ignores scanning while opening a URL`() async {
    let scanner = FakeCodeScanner(scripts: [.events([.scanned("scheme-a://open")])])
    let viewModel = makeViewModel(scanner)
    _ = await viewModel.scan()

    let url = await viewModel.scan()

    #expect(url == nil)
    #expect(scanner.startCount == 1)
  }

  @Test
  func `shows an error when the URL fails to open`() async {
    let scanner = FakeCodeScanner(scripts: [.events([.scanned("scheme-a://open")])])
    let viewModel = makeViewModel(scanner)
    _ = await viewModel.scan()

    viewModel.didFailToOpenURL()

    #expect(viewModel.state.failure == .openingFailed)
  }

  @Test
  func `ignores a failed URL opening while scanning`() {
    let viewModel = makeViewModel(FakeCodeScanner())

    viewModel.didFailToOpenURL()

    #expect(viewModel.state.isScanning)
  }

  @Test(arguments: [
    FakeCodeScanner.Script.events([.scanned("other-scheme://open")]),
    .events([.unavailable]),
    .throwsOnStart,
  ])
  func `retry resumes scanning after a failure`(_ script: FakeCodeScanner.Script) async {
    let viewModel = makeViewModel(FakeCodeScanner(scripts: [script]))
    _ = await viewModel.scan()

    viewModel.retry()

    #expect(viewModel.state.isScanning)
  }

  @Test
  func `retry is ignored while opening a URL`() async {
    let scanner = FakeCodeScanner(scripts: [.events([.scanned("scheme-a://open")])])
    let viewModel = makeViewModel(scanner)
    _ = await viewModel.scan()

    viewModel.retry()

    #expect(viewModel.state.isOpeningURL)
  }

  @Test
  func `a rejected code can be followed by a supported one`() async {
    let scanner = FakeCodeScanner(scripts: [
      .events([.scanned("other-scheme://open")]),
      .events([.scanned("scheme-a://open")]),
    ])
    let viewModel = makeViewModel(scanner)

    let first = await viewModel.scan()
    viewModel.retry()
    let second = await viewModel.scan()

    #expect(first == nil)
    #expect(second == URL(string: "scheme-a://open"))
    #expect(viewModel.state.isOpeningURL)
    #expect(scanner.startCount == 2)
    #expect(scanner.stopCount == 2)
  }
}

private extension CameraScannerViewModel.State {
  var isScanning: Bool {
    if case .scanning = self { true } else { false }
  }

  var isOpeningURL: Bool {
    if case .openingURL = self { true } else { false }
  }

  var isUnavailable: Bool {
    if case .unavailable = self { true } else { false }
  }

  var failure: QRScanError? {
    if case let .failed(error) = self { error } else { nil }
  }
}

// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import Foundation

@MainActor
@Observable
final class CameraScannerViewModel {
  private let scanner: any CodeScanner
  private let supportedSchemes: Set<String>
  private let onSuccess: (URL) -> Void

  private(set) var state: State = .scanning

  var isInfoSheetPresented = false
  var isPaused = false

  var scanError: QRScanError? {
    guard case let .failed(error) = state else { return nil }
    return error
  }

  init(
    scanner: any CodeScanner,
    supportedSchemes: Set<String> = Bundle.urlSchemes(in: Bundle.main.infoDictionary),
    onSuccess: @escaping (URL) -> Void,
  ) {
    self.scanner = scanner
    self.supportedSchemes = supportedSchemes
    self.onSuccess = onSuccess
  }

  func scan() async {
    defer {
      scanner.stop()
    }

    let events: AsyncStream<ScanEvent>
    do {
      events = try scanner.start()
    } catch {
      state = .unavailable
      return
    }

    for await event in events {
      switch event {
        case let .scanned(payload):
          guard case .scanning = state, !isPaused else {
            continue
          }

          guard let url = parseUrl(from: payload) else {
            state = .failed(.unsupportedCode)
            continue
          }

          state = .scanned
          onSuccess(url)

        case .unavailable:
          state = .unavailable
          return
      }
    }
  }

  func retry() {
    guard case .failed = state else {
      return
    }

    state = .scanning
  }

  func presentIsInfoSheet() {
    guard !isInfoSheetPresented else { return }
    isInfoSheetPresented.toggle()
  }

  private func parseUrl(from payload: String) -> URL? {
    guard let url = URL(string: payload),
      let scheme = url.scheme?.lowercased(),
      supportedSchemes.contains(scheme)
    else {
      return nil
    }

    return url
  }
}

extension CameraScannerViewModel {
  enum State {
    case scanning
    case scanned
    case failed(QRScanError)
    case unavailable
  }
}

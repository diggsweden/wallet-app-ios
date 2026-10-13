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
    guard case .scanning = state else { return }

    defer { scanner.stop() }

    let scanning: AsyncStream<ScanEvent>
    do {
      scanning = try scanner.start()
    } catch {
      state = .unavailable
      return
    }

    for await event in scanning {
      switch event {
        case let .scanned(payload):
          guard let url = parseUrl(from: payload) else {
            state = .failed(.unsupportedCode)
            return
          }
          state = .openingURL
          onSuccess(url)
          return

        case .unavailable:
          state = .unavailable
      }
    }
  }

  func retry() {
    switch state {
      case .scanning,
        .openingURL:
        break

      case .failed,
        .unavailable:
        state = .scanning
    }
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
    case openingURL
    case failed(QRScanError)
    case unavailable
  }
}

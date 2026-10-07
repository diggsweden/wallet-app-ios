// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import Foundation

@MainActor
@Observable
final class CameraScannerViewModel {
  private let scanner: any CodeScanner
  private let supportedSchemes: Set<String>

  private(set) var state: State = .scanning

  init(
    scanner: any CodeScanner,
    supportedSchemes: Set<String> = Bundle.urlSchemes(in: Bundle.main.infoDictionary),
  ) {
    self.scanner = scanner
    self.supportedSchemes = supportedSchemes
  }

  func scan() async -> URL? {
    guard case .scanning = state else { return nil }

    defer { scanner.stop() }

    do {
      for await event in try scanner.start() {
        switch event {
          case let .scanned(payload):
            return resolve(payload)

          case .unavailable:
            state = .unavailable
            return nil
        }
      }
    } catch {
      state = .unavailable
    }

    return nil
  }

  func didFailToOpenURL() {
    guard case .openingURL = state else { return }
    state = .failed(.openingFailed)
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

  private func resolve(_ payload: String) -> URL? {
    guard
      let url = URL(string: payload),
      let scheme = url.scheme?.lowercased(),
      supportedSchemes.contains(scheme)
    else {
      state = .failed(.unsupportedCode)
      return nil
    }

    state = .openingURL
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

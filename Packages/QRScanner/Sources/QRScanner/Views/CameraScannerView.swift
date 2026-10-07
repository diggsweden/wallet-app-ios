// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import SwiftUI

struct CameraScannerView: View {
  @Environment(\.openURL) private var openURL
  @Environment(\.dismiss) private var dismiss

  @State private var viewModel: CameraScannerViewModel

  private let session: DataScannerSession
  let isPaused: Bool

  init(session: DataScannerSession, isPaused: Bool) {
    self.session = session
    self.isPaused = isPaused
    _viewModel = State(wrappedValue: CameraScannerViewModel(scanner: session))
  }

  private var shouldScan: Bool {
    guard case .scanning = viewModel.state else { return false }
    return !isPaused
  }

  private var scanError: QRScanError? {
    guard case let .failed(error) = viewModel.state else { return nil }
    return error
  }

  private var isShowingScanError: Binding<Bool> {
    Binding(
      get: { scanError != nil },
      set: { isPresented in
        if !isPresented, scanError != nil {
          viewModel.retry()
        }
      },
    )
  }

  var body: some View {
    Group {
      switch viewModel.state {
        case .scanning, .openingURL, .failed:
          cameraScannerPreview()

        case .unavailable:
          // TODO: Vår error-vy
          EmptyView()
      }
    }
    .task(id: shouldScan) { await scan() }
  }
}

private extension CameraScannerView {
  func cameraScannerPreview() -> some View {
    CameraScannerPreview(controller: session.controller)
      .alert(
        "Kunde inte skanna QR-kod",
        isPresented: isShowingScanError,
        presenting: scanError,
      ) { _ in
        Button("Försök igen") {}
      } message: { error in
        Text(error.errorDescription ?? "")
      }
  }

  func scan() async {
    guard shouldScan else { return }
    guard let url = await viewModel.scan(), !Task.isCancelled else { return }

    openURL(url) { accepted in
      if accepted {
        dismiss()
      } else {
        viewModel.didFailToOpenURL()
      }
    }
  }
}

// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import SwiftUI

struct CameraScannerView<CameraErrorView: View>: View {
  @State private var viewModel: CameraScannerViewModel

  private let session: DataScannerSession
  private let cameraErrorView: CameraErrorView

  let isPaused: Bool

  init(
    session: DataScannerSession,
    isPaused: Bool,
    onSuccess: @escaping (URL) -> Void,
    @ContentBuilder cameraErrorView: () -> CameraErrorView
  ) {
    self.session = session
    self.isPaused = isPaused
    self.cameraErrorView = cameraErrorView()
    _viewModel = State(
      wrappedValue: CameraScannerViewModel(
        scanner: session,
        onSuccess: onSuccess
      )
    )
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
        case .scanning, .scanned, .failed:
          cameraScannerPreview()
            .ignoresSafeArea()

        case .unavailable:
          cameraErrorView
      }
    }
    .task { await viewModel.scan() }
    .onChange(of: isPaused, initial: true) { viewModel.isPaused = isPaused }
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
}

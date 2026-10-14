// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import DesignSystem
import SwiftUI

struct CameraScannerView<CameraErrorView: View>: View {
  @Environment(\.theme) private var theme
  @State private var viewModel: CameraScannerViewModel

  private let session: DataScannerSession
  private let cameraErrorView: CameraErrorView

  init(
    session: DataScannerSession,
    onSuccess: @escaping (URL) -> Void,
    @ContentBuilder cameraErrorView: () -> CameraErrorView
  ) {
    self.session = session
    self.cameraErrorView = cameraErrorView()
    _viewModel = State(
      wrappedValue: CameraScannerViewModel(
        scanner: session,
        onSuccess: onSuccess
      )
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
            .padding(.horizontal, theme.horizontalPadding)
      }
    }
    .toolbar { topToolbar }
    .sheet(isPresented: $viewModel.isInfoSheetPresented) { ScannerInfoView() }
    .task { await viewModel.scan() }
  }
}

private extension CameraScannerView {
  func cameraScannerPreview() -> some View {
    CameraScannerPreview(controller: session.controller)
      .alert(
        "Kunde inte skanna QR-kod",
        isPresented: .constant(viewModel.scanError != nil),
        presenting: viewModel.scanError,
      ) { _ in
        Button("Försök igen") {
          viewModel.retry()
        }
      } message: { error in
        Text(error.errorDescription ?? "")
      }
  }

  @ContentBuilder
  var topToolbar: some ToolbarContent {
    ToolbarItem(placement: .topBarTrailing) {
      Button {
        viewModel.presentIsInfoSheet()
      } label: {
        Image(systemName: "questionmark")
      }
    }
  }
}

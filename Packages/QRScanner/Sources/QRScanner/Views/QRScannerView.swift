// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import AVFoundation
import SwiftUI
import VisionKit

public struct QRScannerView<CameraErrorView: View>: View {
  @Environment(\.dismiss) private var dismiss

  @State private var session = DataScannerSession()
  @State private var isInfoSheetPresented = false

  private let onSuccess: (URL) -> Void
  private let cameraErrorView: CameraErrorView

  public init(
    onSuccess: @escaping (URL) -> Void,
    @ContentBuilder cameraErrorView: () -> CameraErrorView,
  ) {
    self.onSuccess = onSuccess
    self.cameraErrorView = cameraErrorView()
  }

  public var body: some View {
    NavigationStack {
      content
        .sheet(isPresented: $isInfoSheetPresented) { infoSheetContent }
        .task { await session.requestAuthorization() }
        .toolbar { topToolbar }
        .scrollEdgeEffectHiddenIfPossible(for: .top)
    }
    .hiddenStatusBar()
  }
}

private extension QRScannerView {
  @ContentBuilder
  private var content: some View {
    if DataScannerViewController.isAvailable {
      switch session.authorization {
        case .notDetermined:
          ProgressView()

        case .authorized:
          CameraScannerView(
            session: session,
            isPaused: isInfoSheetPresented,
            onSuccess: onSuccess,
            cameraErrorView: { cameraErrorView },
          )

        case .denied, .restricted:
          cameraErrorView

        @unknown default:
          cameraErrorView
      }
    } else {
      cameraErrorView
    }
  }

  @ContentBuilder
  var topToolbar: some ToolbarContent {
    ToolbarItem(placement: .cancellationAction) {
      Button {
        dismiss()
      } label: {
        Image(systemName: "xmark")
      }
    }

    ToolbarItem(placement: .topBarTrailing) {
      Button {
        isInfoSheetPresented.toggle()
      } label: {
        Image(systemName: "questionmark")
      }
    }
  }

  var infoSheetContent: some View {
    Text("Användarinfo går här...")
  }
}

#Preview {
  QRScannerView(
    onSuccess: { _ in },
    cameraErrorView: { EmptyView() },
  )
}

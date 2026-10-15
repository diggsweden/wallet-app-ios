// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import AVFoundation
import DesignSystem
import SwiftUI
import VisionKit

public struct QRScannerView<CameraErrorView: View>: View {
  @Environment(\.theme) private var theme
  @Environment(\.dismiss) private var dismiss

  @State private var session = DataScannerSession()

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
        .task { await session.requestAuthorization() }
        .toolbar { topToolbar }
        .toolbarBackground(.hidden, for: .navigationBar)
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
            onSuccess: onSuccess,
            cameraErrorView: { cameraErrorView },
          )

        case .denied, .restricted:
          cameraErrorView
            .padding(.horizontal, theme.horizontalPadding)

        @unknown default:
          cameraErrorView
            .padding(.horizontal, theme.horizontalPadding)
      }
    } else {
      cameraErrorView
        .padding(.horizontal, theme.horizontalPadding)
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
  }
}

#Preview {
  QRScannerView(
    onSuccess: { _ in },
    cameraErrorView: { EmptyView() },
  )
}

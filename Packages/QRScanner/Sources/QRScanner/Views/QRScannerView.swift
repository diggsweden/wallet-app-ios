// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import AVFoundation
import SwiftUI
import VisionKit

public struct QRScannerView: View {
  @Environment(\.dismiss) private var dismiss

  @State private var session = DataScannerSession()
  @State private var isInfoSheetPresented = false

  public init() {}

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
    if !DataScannerViewController.isSupported {
      // TODO: Vår error-vy
      EmptyView()
    } else {
      switch session.authorization {
        case .notDetermined:
          ProgressView()

        case .authorized:
          CameraScannerView(session: session, isPaused: isInfoSheetPresented)

        case .denied, .restricted:
          // TODO: Vår error-vy
          EmptyView()

        @unknown default:
          // TODO: Vår error-vy
          EmptyView()
      }
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
  QRScannerView()
}

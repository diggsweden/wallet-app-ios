// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import SwiftUI
import VisionKit

struct CameraScannerPreview: UIViewControllerRepresentable {
  let controller: DataScannerViewController

  func makeUIViewController(context: Context) -> DataScannerViewController {
    controller
  }

  func updateUIViewController(_ controller: DataScannerViewController, context: Context) {}

  static func dismantleUIViewController(_ controller: DataScannerViewController, coordinator: ()) {
    controller.stopScanning()
  }
}

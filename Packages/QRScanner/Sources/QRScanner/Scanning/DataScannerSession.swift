// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import AVFoundation
import VisionKit

@MainActor
@Observable
final class DataScannerSession: NSObject, CodeScanner, DataScannerViewControllerDelegate {
  let controller = DataScannerViewController(
    recognizedDataTypes: [.barcode(symbologies: [.qr])],
    qualityLevel: .balanced,
    recognizesMultipleItems: false,
    isHighFrameRateTrackingEnabled: false,
    isPinchToZoomEnabled: true,
    isGuidanceEnabled: false,
    isHighlightingEnabled: false,
  )

  private(set) var authorization = AVCaptureDevice.authorizationStatus(for: .video)

  private var continuation: AsyncStream<ScanEvent>.Continuation?

  override init() {
    super.init()
    controller.delegate = self
  }

  func requestAuthorization() async {
    guard DataScannerViewController.isSupported else { return }
    if AVCaptureDevice.authorizationStatus(for: .video) == .notDetermined {
      _ = await AVCaptureDevice.requestAccess(for: .video)
    }
    authorization = AVCaptureDevice.authorizationStatus(for: .video)
  }

  func start() throws -> AsyncStream<ScanEvent> {
    let (stream, continuation) = AsyncStream.makeStream(
      of: ScanEvent.self,
      bufferingPolicy: .bufferingNewest(1),
    )
    self.continuation = continuation
    try controller.startScanning()
    return stream
  }

  func stop() {
    controller.stopScanning()
    continuation?.finish()
    continuation = nil
  }
}

extension DataScannerSession {
  func dataScanner(
    _ dataScanner: DataScannerViewController,
    didAdd addedItems: [RecognizedItem],
    allItems: [RecognizedItem],
  ) {
    for case let .barcode(barcode) in addedItems {
      guard let payload = barcode.payloadStringValue else { continue }
      continuation?.yield(.scanned(payload))
      return
    }
  }

  func dataScanner(
    _ dataScanner: DataScannerViewController,
    becameUnavailableWithError error: DataScannerViewController.ScanningUnavailable,
  ) {
    continuation?.yield(.unavailable)
  }
}

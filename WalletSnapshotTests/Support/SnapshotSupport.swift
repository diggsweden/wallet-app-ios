// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import SnapshotTesting
import SwiftUI
import Testing

@testable import WalletDemo

private let isScreenshotbot = ProcessInfo.processInfo.environment["SCREENSHOTBOT"] == "1"

@MainActor
func assertThemedSnapshots(
  of view: some View,
  width: CGFloat? = nil,
  padding: CGFloat = 16,
  displayScale: CGFloat = 3,
  precision: Float = 1,
  perceptualPrecision: Float = 0.98,
  fileID: StaticString = #fileID,
  file filePath: StaticString = #filePath,
  testName: String = #function,
  line: UInt = #line,
  column: UInt = #column,
) {
  for scheme in [ColorScheme.light, .dark] {
    let name = scheme == .dark ? "dark" : "light"
    let style: UIUserInterfaceStyle = scheme == .dark ? .dark : .light
    let content =
      view
      .frame(width: width)
      .padding(padding)
      .themed
      .environment(\.colorScheme, scheme)
    let traits = UITraitCollection { mutableTraits in
      mutableTraits.userInterfaceStyle = style
      mutableTraits.displayScale = displayScale
    }
    assertWalletSnapshot(
      of: content,
      as: .image(precision: precision, perceptualPrecision: perceptualPrecision, traits: traits),
      named: name,
      fileID: fileID,
      file: filePath,
      testName: testName,
      line: line,
      column: column,
    )
  }
}

@MainActor
func assertThemedDeviceSnapshots(
  of view: some View,
  device: ViewImageConfig = .iPhone13Pro,
  precision: Float = 1,
  perceptualPrecision: Float = 0.98,
  fileID: StaticString = #fileID,
  file filePath: StaticString = #filePath,
  testName: String = #function,
  line: UInt = #line,
  column: UInt = #column,
) {
  for scheme in [ColorScheme.light, .dark] {
    let name = scheme == .dark ? "dark" : "light"
    let style: UIUserInterfaceStyle = scheme == .dark ? .dark : .light
    let content =
      view
      .themed
      .environment(\.colorScheme, scheme)
    let traits = UITraitCollection { mutableTraits in
      mutableTraits.userInterfaceStyle = style
      mutableTraits.displayScale = device.traits.displayScale
    }
    assertWalletSnapshot(
      of: content,
      as: .image(
        precision: precision,
        perceptualPrecision: perceptualPrecision,
        layout: .device(config: device),
        traits: traits,
      ),
      named: name,
      fileID: fileID,
      file: filePath,
      testName: testName,
      line: line,
      column: column,
    )
  }
}

/// Without `SCREENSHOTBOT=1` this forwards straight to `assertSnapshot`.
func assertWalletSnapshot<Value, Format>(
  of value: @autoclosure () throws -> Value,
  as snapshotting: Snapshotting<Value, Format>,
  named name: String? = nil,
  timeout: TimeInterval = 5,
  fileID: StaticString = #fileID,
  file filePath: StaticString = #filePath,
  testName: String = #function,
  line: UInt = #line,
  column: UInt = #column,
) {
  guard isScreenshotbot else {
    assertSnapshot(
      of: try value(),
      as: snapshotting,
      named: name,
      timeout: timeout,
      fileID: fileID,
      file: filePath,
      testName: testName,
      line: line,
      column: column,
    )
    return
  }

  let failure = verifySnapshot(
    of: try value(),
    as: snapshotting,
    named: name,
    record: .all,
    timeout: timeout,
    fileID: fileID,
    file: filePath,
    testName: testName,
    line: line,
    column: column,
  )

  guard let message = failure else { return }

  let recordNoticePrefixes = [
    "Record mode is on",
    "No reference was found on disk",
  ]
  guard !recordNoticePrefixes.contains(where: message.hasPrefix) else { return }

  Issue.record(
    Comment(rawValue: message),
    sourceLocation: SourceLocation(
      fileID: fileID.description,
      filePath: filePath.description,
      line: Int(line),
      column: Int(column),
    ),
  )
}

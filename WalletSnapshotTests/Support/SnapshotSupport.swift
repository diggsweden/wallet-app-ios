// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import SnapshotTesting
import SwiftUI
import Testing

@testable import WalletDemo

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
    assertSnapshot(
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
    assertSnapshot(
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

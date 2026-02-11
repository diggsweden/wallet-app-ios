// SPDX-FileCopyrightText: 2026 diggsweden/wallet-app-ios
//
// SPDX-License-Identifier: EUPL-1.2

import SwiftUI

enum Orientation {
  case portrait, landscape

  var isLandscape: Bool { self == .landscape }
}

extension EnvironmentValues {
  @Entry var orientation: Orientation = .portrait
}

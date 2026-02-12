// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
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

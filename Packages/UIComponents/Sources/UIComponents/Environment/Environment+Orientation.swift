// SPDX-FileCopyrightText: 2026 Digg - Agency for digital government
//
// SPDX-License-Identifier: EUPL-1.2

import SwiftUI

public enum Orientation {
  case portrait, landscape

  public var isLandscape: Bool { self == .landscape }
}

extension EnvironmentValues {
  @Entry public var orientation: Orientation = .portrait
}

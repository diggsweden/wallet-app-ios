import SwiftUI

enum Orientation {
  case portrait, landscape

  var isLandscape: Bool { self == .landscape }
}

extension EnvironmentValues {
  @Entry var orientation: Orientation = .portrait
}

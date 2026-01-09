import SwiftUI

extension View {
  @ViewBuilder
  func lineHeightIfAvailable(multiple factor: CGFloat?) -> some View {
    if #available(iOS 26.0, *) {
      if let factor {
        self.lineHeight(.multiple(factor: factor))
      } else {
        self.lineHeight(nil)
      }
    } else {
      self
    }
  }
}

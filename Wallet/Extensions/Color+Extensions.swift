import SwiftUI

extension Color {
  static func rgba(_ r: Double, _ g: Double, _ b: Double, _ a: Double = 1.0) -> Color {
    Color(
      red: r / 255,
      green: g / 255,
      blue: b / 255,
      opacity: a
    )
  }
}

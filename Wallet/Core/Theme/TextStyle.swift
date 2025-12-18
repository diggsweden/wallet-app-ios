import SwiftUI

struct TextMetrics {
  let font: Font
  let lineHeightFactor: CGFloat?
}

enum TextStyle {
  case h1,
    h2,
    h3,
    h4,
    h5,
    h6,
    body,
    bodyLarge,
    bodySmall,
    caption,
    caption2

  var metrics: TextMetrics {
    return switch self {
      case .h1:
        TextMetrics(
          font: .custom("Ubuntu-Bold", size: 32, relativeTo: .largeTitle),
          lineHeightFactor: nil
        )
      case .h2:
        TextMetrics(
          font: .custom("Ubuntu-Bold", size: 24, relativeTo: .title),
          lineHeightFactor: nil
        )
      case .h3:
        TextMetrics(
          font: .custom("Ubuntu-Bold", size: 20, relativeTo: .title3),
          lineHeightFactor: nil
        )
      case .h4:
        TextMetrics(
          font: .custom("Ubuntu-Bold", size: 18, relativeTo: .title3),
          lineHeightFactor: nil
        )
      case .h5:
        TextMetrics(
          font: .custom("Ubuntu-Bold", size: 16, relativeTo: .title3),
          lineHeightFactor: nil
        )
      case .h6:
        TextMetrics(
          font: .custom("Ubuntu-Bold", size: 14, relativeTo: .title3),
          lineHeightFactor: 1.142
        )
      case .body:
        TextMetrics(
          font: .custom("Ubuntu-Regular", size: 16, relativeTo: .body),
          lineHeightFactor: 1.5
        )
      case .bodyLarge:
        TextMetrics(
          font: .custom("Ubuntu-Regular", size: 18, relativeTo: .body),
          lineHeightFactor: 1.777
        )
      case .bodySmall:
        TextMetrics(
          font: .custom("Ubuntu-Regular", size: 14, relativeTo: .body),
          lineHeightFactor: 1.428
        )
      case .caption:
        TextMetrics(
          font: .custom("Ubuntu-Regular", size: 12, relativeTo: .caption),
          lineHeightFactor: nil
        )
      case .caption2:
        TextMetrics(
          font: .custom("Ubuntu-Regular", size: 10, relativeTo: .caption2),
          lineHeightFactor: nil
        )
    }
  }
}

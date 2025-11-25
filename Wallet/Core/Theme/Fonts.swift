import SwiftUI

struct Fonts {
  let h1: Font = .custom("Ubuntu-Bold", size: 48, relativeTo: .largeTitle)
  let h2: Font = .custom("Ubuntu-Bold", size: 32, relativeTo: .largeTitle)
  let h3: Font = .custom("Ubuntu-Bold", size: 24, relativeTo: .largeTitle)
  let h4: Font = .custom("Ubuntu-Bold", size: 20, relativeTo: .title2)
  let h5: Font = .custom("Ubuntu-Bold", size: 18, relativeTo: .title)
  let h6: Font = .custom("Ubuntu-Bold", size: 14, relativeTo: .title3)
  let body: Font = .custom("Ubuntu-Regular", size: 16, relativeTo: .body)
  let bodySmall: Font = .custom("Ubuntu-Regular", size: 14, relativeTo: .caption)
  let bodyLarge: Font = .custom("Ubuntu-Regular", size: 18, relativeTo: .body)
  let caption: Font = .custom("Ubuntu-Regular", size: 12, relativeTo: .caption)
  let caption2: Font = .custom("Ubuntu-Regular", size: 10, relativeTo: .caption2)
}

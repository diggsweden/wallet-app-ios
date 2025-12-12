import SwiftUI

struct OnboardingBottomToolbarButton<Content: View>: ToolbarContent {
  @ViewBuilder let content: () -> Content

  var body: some ToolbarContent {
    if #available(iOS 26.0, *) {
      ToolbarItem(placement: .bottomBar) {
        content()
          .frame(maxWidth: .infinity)
          .padding(32)
      }
      .sharedBackgroundVisibility(.hidden)
    } else {
      ToolbarItem(placement: .bottomBar) {
        content()
          .frame(maxWidth: .infinity)
          .padding(32)
      }
    }
  }
}

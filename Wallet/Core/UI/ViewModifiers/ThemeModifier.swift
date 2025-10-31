import SwiftUI

struct ThemeModifier: ViewModifier {
  @Environment(\.colorScheme) private var scheme

  func body(content: Content) -> some View {
    let theme = (scheme == .dark) ? Theme.dark : Theme.light
    return
      content
      .environment(\.theme, theme)
      .environment(\.font, theme.fonts.body)
      .foregroundStyle(theme.colors.textPrimary)
  }
}

extension View {
  var themed: some View { modifier(ThemeModifier()) }
}

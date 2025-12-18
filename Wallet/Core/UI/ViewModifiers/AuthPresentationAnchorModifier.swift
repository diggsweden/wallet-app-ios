import AuthenticationServices
import SwiftUI

struct AuthPresentationAnchorModifier: ViewModifier {
  @State private var anchor: ASPresentationAnchor?

  func body(content: Content) -> some View {
    content
      .background(
        PresentationAnchorProvider { window in
          guard let window, window !== anchor else {
            return
          }

          anchor = window
        }
      )
      .environment(\.authPresentationAnchor, anchor)
  }
}

extension View {
  var withAuthPresentationAnchor: some View {
    modifier(AuthPresentationAnchorModifier())
  }
}

import AuthenticationServices
import SwiftUI

extension EnvironmentValues {
  @Entry var authAnchor: ASPresentationAnchor? = nil
}

struct AuthAnchorReader: UIViewRepresentable {
  var onResolve: (UIWindow?) -> Void

  func makeUIView(context: Context) -> UIView {
    let v = UIView()

    DispatchQueue.main.async {
      onResolve(v.window)
    }
    return v
  }

  func updateUIView(_ uiView: UIView, context: Context) {
    DispatchQueue.main.async {
      onResolve(uiView.window)
    }
  }
}

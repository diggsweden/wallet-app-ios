import SwiftUI

struct LoginView: View {
  @Environment(\.openURL) private var openURL
  var body: some View {
    Text("Login View")
    Spacer()
    PrimaryButton("Logga in") {
      var components = URLComponents(url: AppConfig.apiBaseURL, resolvingAgainstBaseURL: false)
      components?.path += "/oidc/auth"

      guard let url = components?.url else {
        return
      }

      openURL(url)
    }
  }
}

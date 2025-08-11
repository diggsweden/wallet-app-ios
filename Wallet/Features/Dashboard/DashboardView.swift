import SwiftUI

struct DashboardView: View {
  let credential: Credential?
  @Environment(\.openURL) var openURL

  var body: some View {
    ScrollView {
      VStack(alignment: .center, spacing: 20) {
        VStack(alignment: .center) {
          Image(.diggLogo).resizable().frame(width: 80, height: 80)
          Text("ID-plånboken").font(.caption)
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)

        Text("dashboard_welcome")
          .font(.title)
          .padding(.top, 10)
        Text("dashboard_content_1")

        VStack {
          if let credential {
            CredentialView(credential: credential)
          }
          CredentialView(credential: nil)
        }
      }
      .padding(.horizontal, 30)
    }
  }
}

#Preview {
  DashboardView(credential: nil)
    .environment(NavigationModel())
}

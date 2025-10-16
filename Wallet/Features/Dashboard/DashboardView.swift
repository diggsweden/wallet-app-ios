import SwiftUI

struct DashboardView: View {
  let credential: Credential?
  @Environment(Router.self) private var router
  @Environment(\.theme) private var theme

  var body: some View {
    ScrollView {
      VStack(alignment: .center, spacing: 20) {
        Text("dashboard_welcome")
          .font(theme.fonts.title)
          .padding(.top, 10)
        Text("dashboard_content_1")

        VStack {
          if let credential {
            CredentialCard(credential: credential)
          }
          CredentialCard(credential: nil)
        }
      }
      .padding(.horizontal, 30)
    }
    .toolbar {
      ToolbarItem(placement: .title) {
        HStack {
          Image(.diggLogo).resizable().frame(width: 24, height: 24)
          Text("ID-plånboken").font(theme.fonts.caption)
        }
      }
      ToolbarItem(placement: .topBarTrailing) {
        Button {
          router.go(to: .settings)
        } label: {
          Image(systemName: "gearshape")
        }
      }
    }
    .background(.clear)
    .toolbarRole(.editor)
  }
}

#Preview {
  DashboardView(credential: nil)
    .environment(Router())
}

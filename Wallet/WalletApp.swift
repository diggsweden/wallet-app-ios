import SwiftUI

@main
struct WalletApp: App {
  var body: some Scene {
    WindowGroup {
      RootView()
    }
  }
}

struct RootView: View {
  @State var navigationModel = NavigationModel()
  let credential: Credential?

  init() {
    credential =
      if let credentialString = UserDefaults.standard.string(forKey: "credential") {
        try? JSONDecoder().decode(Credential.self, from: Data(credentialString.utf8))
      } else {
        nil
      }
  }

  var body: some View {
    NavigationStack(path: $navigationModel.navigationPath) {
      DashboardView(credential: credential)
        .navigationDestination(for: Route.self) { route in
          switch route {
            case .presentation(let data):
              if let credential {
                PresentationView(vpTokenData: data, credential: credential)
              } else {
                Text("No credential found!")
              }
            case .issuance(let url):
              IssuanceView(credentialOfferUri: url)
          }
        }
        .onOpenURL { url in
          Task {
            do {
              let deeplink = try Deeplink(from: url)
              let route = try await deeplink.router.route(from: url)
              navigationModel.go(to: route)
            } catch {
              print("Failed to deeplink: \(error)")
              return
            }
          }
        }
    }
    .environment(navigationModel)
  }
}

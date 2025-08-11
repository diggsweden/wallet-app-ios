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
  @AppStorage("credential") private var credentialString: String?
  @State var credential: Credential?
  @State var navigationModel = NavigationModel()

  var body: some View {
    NavigationStack(path: $navigationModel.navigationPath) {
      DashboardView(credential: credential)
        .navigationDestination(for: Route.self) { route in
          switch route {
            case .presentation(let data):
              if let credential {
                PresentationView(vpTokenData: data, credential: credential)
              } else {
                Text("No credential found on device!")
              }
            case .issuance(let url):
              IssuanceView(credentialOfferUri: url)
            case .credentialDetails(let credential):
              CredentialDetailsView(credential: credential)
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
        .task(id: credentialString) {
          guard let credentialString else {
            return
          }
          credential = try? JSONDecoder().decode(Credential.self, from: credentialString.utf8Data)
        }
    }
    .environment(navigationModel)
  }
}

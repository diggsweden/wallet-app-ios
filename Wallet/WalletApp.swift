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

  var body: some View {
    NavigationStack(path: $navigationModel.navigationPath) {
      DashboardView()
        .navigationDestination(for: Route.self) { route in
          switch route {
            case .presentation(let definition):
              PresentationView(presentationDefinition: definition)
            case .issuance(let url):
              IssuanceView(credentialOfferUri: url)
          }
        }
        .onOpenURL { url in
          print("URL: absolute " + url.absoluteString)
          Task {
            do {
              let deeplink = try Deeplink(from: url)
              let route = try await deeplink.router.route(from: url)
              navigationModel.go(to: route)
            }
            catch {
              print("Failed to deeplink: \(error)")
              return
            }

          }
        }
    }
    .environment(navigationModel)
  }
}

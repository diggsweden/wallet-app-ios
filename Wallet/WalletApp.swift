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
            guard
              let deeplink = Deeplink(from: url),
              let route = try? await deeplink.router.route(from: url)
            else {
              print("Unsupported URL: \(url)")
              return
            }

            navigationModel.go(to: route)
          }
        }
    }
  }
}

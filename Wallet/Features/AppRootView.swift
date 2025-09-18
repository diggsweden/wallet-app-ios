import SwiftData
import SwiftUI

struct AppRootView: View {
  @Environment(\.modelContext) private var modelContext
  @State var navigationModel = NavigationModel()
  @Query private var wallets: [Wallet]
  private var wallet: Wallet? { wallets.first }

  var body: some View {
    NavigationStack(path: $navigationModel.navigationPath) {
      DashboardView(credential: wallet?.credential, onLogout: logout)
        .navigationDestination(for: Route.self, destination: routeView)
        .onOpenURL(perform: handleOpenURL)
    }
    .environment(navigationModel)
  }

  @ViewBuilder
  private func routeView(_ route: Route) -> some View {
    switch route {
      case .presentation(let data):
        if let credential = wallet?.credential {
          PresentationView(vpTokenData: data, credential: credential)
        } else {
          Text("No credential found on device!")
        }
      case .issuance(let url):
        IssuanceView(credentialOfferUri: url, wallet: wallet)
      case .credentialDetails(let credential):
        CredentialDetailsView(credential: credential)
      case .provisioning:
        EnrollmentRootView()
    }
  }

  private func handleOpenURL(_ url: URL) {
    Task {
      do {
        let deeplink = try Deeplink(from: url)
        let route = try await deeplink.router.route(from: url)
        navigationModel.go(to: route)
      } catch {
        print("Failed to deeplink: \(error)")
      }
    }
  }

  private func logout() {
    try? modelContext.delete(model: User.self)
    try? modelContext.delete(model: Wallet.self)
  }
}

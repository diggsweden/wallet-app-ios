import SwiftData
import SwiftUI

struct AppRootView: View {
  private enum RootDestination {
    case dashboard, enrollment
  }

  @Environment(\.modelContext) private var modelContext
  @State private var navigationModel = NavigationModel()
  @Query private var sessions: [AppSession]
  private var session: AppSession? { sessions.first }

  private var isEnrolled: Bool { session?.user != nil && session?.wallet != nil }
  private var rootDestination: RootDestination {
    isEnrolled ? .dashboard : .enrollment
  }

  var body: some View {
    NavigationStack(path: $navigationModel.navigationPath) {
      rootView
        .navigationDestination(for: Route.self, destination: destination)
        .onOpenURL(perform: handleOpenURL)
    }
    .environment(navigationModel)
    .task(id: session) {
      initSession()
    }
  }

  private func initSession() {
    guard session == nil else {
      return
    }

    modelContext.insert(AppSession())
    try? modelContext.save()
  }

  @ViewBuilder private var rootView: some View {
    switch rootDestination {
      case .dashboard:
        DashboardView(credential: session?.wallet?.credential, onLogout: logout)
      case .enrollment:
        EnrollmentView(appSession: session)
    }
  }

  @ViewBuilder
  private func destination(for route: Route) -> some View {
    switch route {
      case .presentation(let data):
        if let credential = session?.wallet?.credential {
          PresentationView(vpTokenData: data, credential: credential)
        } else {
          Text("No credential found on device!")
        }
      case .issuance(let url):
        IssuanceView(credentialOfferUri: url, wallet: session?.wallet)
      case .credentialDetails(let credential):
        CredentialDetailsView(credential: credential)
    }
  }

  private func handleOpenURL(_ url: URL) {
    guard isEnrolled else {
      return
    }

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
    try? modelContext.delete(model: AppSession.self)
    try? modelContext.save()
  }
}
